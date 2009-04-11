module AdministrateMe
  module AdminScaffold
    module InstanceMethods

      def get_list
        session[:mini] = ''
        params[:search_key] ||= session["#{controller_name}_search_key"] if session["#{controller_name}_search_key"]
        @search_key = params[:search_key]
        get_records
        set_search_message
        session["#{controller_name}_search_key"] = @search_key
      end

      def get_records
        conditions = model_class.merge_conditions_backport(*[parent_scope, global_scope, search_scope])
        options = {:conditions => conditions, :include => get_includes, :order => get_order}
        if model_class.respond_to?('paginate') && !show_all_records?
          @records = apply_scopes.paginate(options.merge(:page => params[:page], :per_page => get_per_page))
          @count_for_search = @records.total_entries
        else
          @records = apply_scopes.find(:all, options)
          @count_for_search = @records.size
        end
      end

      def apply_scopes
        final_scope = model_class.scoped({})
        filter_scopes.each do |scope|
          final_scope = final_scope.scoped(scope)
        end
        final_scope
      end

      def filter_scopes
        scopes = []
        if filter_config
          scopes << filter_config.options_for_filter(self, active_filter)
          session[:combo_filters][self.class.to_s].each do |filter_name, value|
            if value
              scopes << filter_config.options_for_filter(self, filter_name, value)
            end
          end
        end
        scopes.compact
      end

      def get_per_page
        options[:per_page] || model_class.per_page || 15
      end

      def get_includes
        options[:includes] || nil
      end

      def get_order
        options[:order_by] || nil
      end

      def get_list_options
        list_options = {}
        list_options[:per_page] = (options[:per_page]) ? options[:per_page] : 15
        list_options[:order]    = options[:order_by] rescue nil
        list_options
      end

      def set_search_message
        if options[:search] && !params[:search_key].blank?
          session[:mini] = I18n.t('messages.search_message', :count => @count_for_search, :search_key => @search_key)
        end
      end

      def parent_scope
        parent = options[:parent]
        foreign_key = options[:foreign_key].blank? ? "#{options[:parent]}_id" : options[:foreign_key]
        if parent
          { foreign_key => @parent.id }
        end
      end

      def global_scope
        respond_to?('general_conditions') ? general_conditions : nil
      end   

      def search_scope
        !@search_key.blank? && options[:search] ? conditions_for(options[:search]) : nil
      end

      def filter_scope
        if filter_config
          conditions = []
          conditions << filter_config.conditions_for_filter(self, active_filter)
          session[:combo_filters][self.class.to_s].each do |filter_name, value|
            if value
              filter = filter_config.filter_by_name(self, filter_name)
              conditions << filter.conditions(value)
            end
          end
          model_class.merge_conditions_backport(*conditions)
        end
      end

      def index
        get_list
        call_before_render
        unless performed?
          respond_to do |format|
            format.html { render :template => 'commons/index' }
            format.js   {
              render :update do |page|
                page.replace_html :list_area, :partial => 'list'
              end
            }
            format.xml  { render :xml => @records.to_xml }
            format.xls do
              headers['Content-Disposition'] = %{attachment; filename="#{controller_name}.xls"}
              headers['Cache-Control'] = ''
              render :layout => false, :inline => "<%= render :partial => 'list.html.erb' %>"
            end
          end
        end
      end

      def show
        if_available(:show) do
          call_before_render
          unless performed?
            respond_to do |format|
              format.html # show.rhtml
              format.xml  { render :xml => @resource.to_xml }
            end
          end
        end
      end

      def new
        if_available(:new) do
          @resource = ( options[:model] ? options[:model] : controller_name ).classify.constantize.new
          call_before_render
          unless performed?
            render :template => 'commons/base_form'
          end
        end
      end

      def edit
        if_available(:edit) do
          call_before_render
          unless performed?
            render :template => 'commons/base_form'
          end
        end
      end

      def create
        if_available(:new) do
          create_params = params[model_name.to_sym]
          if parent = options[:parent]
            create_params[parent_key.to_sym] = @parent.id
          end
          @resource = model_class.new(create_params)
          save_model
          call_before_render
          unless performed?
            respond_to do |format|
              if @success
                flash[:notice] = I18n.t('messages.create_success')
                session["#{controller_name}_search_key"] = nil
                format.html { redirect_to path_to_index }
                format.xml  { head :created, :location => eval("#{controller_name.singularize}_url(@resource)") }
              else
                format.html { render :template => "commons/base_form" }
                format.xml  { render :xml => @resource.errors.to_xml }
              end
            end
          end
        end
      end

      def update
        if_available(:edit) do
          @resource.attributes = params[model_name.to_sym]
          save_model
          call_before_render
          unless performed?
            respond_to do |format|
              if @success
                flash[:notice] = I18n.t('messages.save_success')
                format.html { redirect_to path_to_element(@resource) }
                format.xml  { head :ok }
              else
                format.html { render :template => "commons/base_form" }
                format.xml  { render :xml => @resource.errors.to_xml }
              end
            end
          end
        end
      end

      def destroy
        if_available(:destroy) do
          call_callback_on_action 'before', 'destroy'
          if @success = @resource.destroy
            call_callback_on_action 'after', 'destroy'
          end
          call_before_render
          unless performed?
            respond_to do |format|
              if @success
                flash[:notice] = I18n.t('messages.destroy_success')
                format.html { redirect_to path_to_index }
                format.xml  { head :ok }
              else
                format.html { render :template => "commons/base_form" }
                format.xml  { head :error }
              end
            end
          end
        end
      end

      #FIXME: I need some testing!
      def path_to_index(*args)
        local_options = args.last.is_a?(Hash) ? args.pop : nil
        prefix  = args.first
        parts = []
        # add prefix
        parts << prefix if prefix
        nspace = self.class.namespace ? self.class.namespace.gsub('/', '_') : nil
        # add namespace
        parts << nspace if nspace
        # add parent
        parent = options[:parent]
        parts << options[:parent] unless parent.blank?
        # add controller
        cname = prefix ? controller_name.singularize : controller_name
        parts << cname
        #
        parts << 'path'
        helper_name = parts.join('_')
        parameters = []
        parameters << params[:"#{parent}_id"] unless parent.blank?
        parameters << local_options if local_options
        send(helper_name, *parameters)
      end

      def path_to_element(element, options = {})
        options[:parent] ||= self.options[:parent]
        create_path(self.controller_name.singularize, element, self.class.namespace, @parent, options)
      end
      
      def path_to_parent(parent, options = {})
        create_path(parent.class.to_s.underscore, parent, self.class.namespace, options)
      end

      def get_index
        path  = "#{controller_name}_path"
        unless options[:parent].blank?
          path << "(params[:#{options[:parent].to_s}_id])"
        end
        eval(path)
      end

      def model_name
        self.class.model_name
      end

      def model_class
        self.class.model_class
      end

      def parent_class
        self.class.parent_class
      end

      def parent_key
        options[:foreign_key] || "#{options[:parent]}_id".to_sym
      end

      # By default the search conditions will be created OR'ing all fields
      # on the administrate_me configuration using the LIKE sql clause.
      #
      # == Example
      #
      #   class PeopleController < ApplicationController
      #     administrate_me do |a|
      #       a.search :first_name, :last_name
      #     end
      #   end
      #
      # The condition will be along the lines of:
      #
      #   lower(first_name) LIKE '%john%' OR lower(last_name) LIKE '%john%'
      #
      def conditions_for(fields=[])
        predicate = []
        values    = []
        fields.each do |field|
          predicate << "lower(#{field.to_s}) like ?"
          values    << "'%' + @search_key.downcase + '%'"
        end
        eval("[\"#{predicate.join(' OR ')}\", #{values.join(',')}]")
      end

      def active_filter
        session[:active_filters] ? session[:active_filters][self.class.to_s] : nil
      end

      def active_combo_filters
        session[:combo_filters][self.class.to_s].keys
      end

      def combo_filters
        session[:combo_filters][self.class.to_s]
      end

      # Simplifies action_name handling for accepted_action?()
      def translated_action_name(action)
        case action
        when :update
          :edit
        when :create
          :new
        else
          action
        end
      end

      def accepted_action?(action)
        translated_action = translated_action_name(action)
        allowed = options[:except].empty? || !options[:except].include?(translated_action)
        if allowed && options[:except_block]
          allowed = self.instance_exec(translated_action, &options[:except_block])
        end
        allowed
      end

      def filter_config
        self.options[:filter_config]
      end

      def show_all_records?
        !params[:all].blank? || params[:format] == 'xls'
      end

      protected

        def get_resource
          if %w{show edit update destroy}.include?(self.action_name) && accepted_action?(self.action_name)
            @resource = model_class.find(params[:id])
          end
        end   

        def habtm_callback
          options[:habtms].each do |habtm|
            params[model_name.to_sym]["#{habtm.to_s.singularize}_ids".to_sym] ||= []
          end
        end

        def if_available(action)
          if self.accepted_action?(action)
            yield
          else
            raise ActionController::UnknownAction
          end
        end

        def save_model
          begin
            model_class.transaction do 
              call_callback           'before', 'save'
              call_callback_on_action 'before', 'create'
              call_callback_on_action 'before', 'update'
              if @success = @resource.save!
                call_callback           'after', 'save'
                call_callback_on_action 'after', 'create'
                call_callback_on_action 'after', 'update'
              end
            end
          rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
            logger.error(I18n.t('errors.exception_on_save', :message => $!))
            @success = false
          end
        end       

        # will execute the callback only when the controller executes the 
        # specific action.
        def call_callback_on_action(hook, actions)
          actions_array = [*actions]
          call_callback(hook, actions_array.join('_and_')) if actions_array.include?(action_name.to_sym)
        end
        
        # will execute a callback
        def call_callback(hook, action)
          method_name = "#{hook}_#{action}"
          send(method_name) if respond_to?(method_name)
        end

        def get_parent
          if parent = options[:parent]
            begin
              @parent = parent_class.find(params[:"#{parent}_id"])
            rescue ActiveRecord::RecordNotFound
              flash[:error] = I18n.t('messages.missing_parent')
              #FIXME: Where this case should redirect_to ?
              redirect_to ''
              return false
            end
          end
        end

        def set_active_filter
          session[:active_filters] ||= {}
          session[:combo_filters] ||= {}
          session[:combo_filters][self.class.to_s] ||= {}
          if params[:filter]
            session[:active_filters][self.class.to_s] = params[:filter] != 'none' ? params[:filter] : nil
          end
          if params[:combo_filter]
            session[:combo_filters][self.class.to_s][params[:combo_filter]] = !params[:combo_value].blank? ? params[:combo_value] : nil
          end
        end

        def generate_url
          html  = "url("
          unless options[:parent].blank?
            html << "@resource.send(:#{options[:parent]}_id), "
          end
          html << "@resource)"
          html
        end

        def call_before_render
          before_render if respond_to?('before_render')
          call_callback_on_action :before_render, :new
          call_callback_on_action :before_render, :create
          call_callback_on_action :before_render, [:new, :create]
          call_callback_on_action :before_render, :edit
          call_callback_on_action :before_render, :update
          call_callback_on_action :before_render, [:edit, :update]
          before_render_with_form if [:new, :create, :edit, :update].include?(action_name.to_sym) && respond_to?('before_render_with_form')
          call_callback_on_action :before_render, :index
          call_callback_on_action :before_render, :show
          call_callback_on_action :before_render, :destroy
        end

    end
  end

  module InstanceMethods

    def create_path(controller_name, element, namespace, parent, options = {})
      parts = []
      # add prefix
      parts << options[:prefix] if options[:prefix]
      # add namespace
      parts << namespace.gsub('/', '_') if namespace
      # add parent
      parts << options[:parent] if options[:parent]
      # add controller
      parts << controller_name
      #
      parts << 'path'
      helper_name = parts.join('_')
      ids = [element]
      ids.unshift parent unless parent.blank?
      send(helper_name, *ids)
    end

  end
end
