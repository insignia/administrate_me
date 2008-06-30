module AdministrateMe::AdminScaffold

  module InstanceMethods
  
    def get_list    
      session[:mini] = ''
      @search_key = params[:search_key]
      model_class.send(:with_scope, :find => { :conditions => parent_scope }) do
        model_class.send(:with_scope, :find => { :conditions => global_scope }) do
          model_class.send(:with_scope, :find => { :conditions => search_scope }) do
            if model_class.respond_to?('paginate')
              @records = model_class.paginate(:include => get_includes, :page => params[:page], :per_page => get_per_page, :order => get_order )
            else
              @records = model_class.find(:all, :include => get_includes, :order => get_order )
            end
            set_search_message
          end
        end
      end
    end  
    
    def get_per_page
      options[:per_page] || 15
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
      unless params[:search_key].blank?        
        session[:mini] = search_message(@search_key) 
      end
    end
    
    def parent_scope
      if parent = options[:parent]
        { "#{parent}_id" => params["#{parent}_id"] }
      end
    end

    def global_scope
      gc = respond_to?('general_conditions') ? general_conditions : nil
      if gc
        gc.merge(session["#{controller_name}"]) if session["#{controller_name}"]          
      else
        gc = session["#{controller_name}"] if session["#{controller_name}"]  
      end
      gc
    end   
    
    def search_scope
      sc = @search_key.blank? ? nil : conditions_for(options[:search])
    end   
  
    def index
      get_list
      call_before_render
      respond_to do |format|
        format.html { render :template => 'commons/index' }
        format.xml  { render :xml => @records.to_xml }
      end
    end    
    
    def search    
      get_list
      render :partial => 'list'    
    end
    
    def show
      if_available(:show) do 
        call_before_render
        respond_to do |format|
          format.html # show.rhtml
          format.xml  { render :xml => @resource.to_xml }      
        end
      end
    end
    
    def new    
      if_available(:new) do
        @resource = ( options[:model] ? options[:model] : controller_name ).classify.constantize.new
        call_before_render
        render :template => 'commons/new'
      end
    end
    
    def edit
      if_available(:edit) do
        call_before_render
        render :template => 'commons/edit'
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
        respond_to do |format|
          if @success
            flash[:notice] = 'El registro fue creado exitosamente'        
            format.html { redirect_to path_to_index }
            format.xml  { head :created, :location => eval("#{controller_name.singularize}_url(@resource)") }
          else
            format.html { render :template => "commons/new" }
            format.xml  { render :xml => @resource.errors.to_xml }        
          end
        end
      end
    end
    
    def update 
      if_available(:edit) do 
        @resource.attributes = params[model_name.to_sym]
        save_model
        call_before_render
        respond_to do |format|
          if @success
            flash[:notice] = 'Los cambios fueron guardados exitosamente'
            format.html { redirect_to path_to_element(@resource) }
            format.xml  { head :ok }
          else
            format.html { render :template => "commons/edit" }        
            format.xml  { render :xml => @resource.errors.to_xml }
          end
        end
      end
    end
    
    def destroy
      if_available(:destroy) do
        @resource.destroy
        call_before_render
        respond_to do |format|
          flash[:notice] = 'El registro fue eliminado exitosamente.'
          format.html { redirect_to path_to_index }      
          format.xml  { head :ok }
        end
      end
    end
    
    def path_to_index(prefix=nil)
      parts = []
      # Agregar prefijo
      parts << prefix if prefix
      nspace = self.class.namespace
      # Agregar namespace
      parts << nspace if nspace
      # Agregar parent
      parent = options[:parent]
      parts << options[:parent] unless parent.blank?
      # Agregar controller
      cname = prefix ? controller_name.singularize : controller_name
      parts << cname
      #
      parts << 'path'
      helper_name = parts.join('_')
      ids = []
      ids << params[:"#{parent}_id"] unless parent.blank?
      send(helper_name, *ids)
    end
    
    def path_to_element(element, options = {})
      parts = []
      # Agregar prefijo
      parts << options[:prefix] if options[:prefix]
      # Agregar namespace
      nspace = self.class.namespace
      parts << nspace if nspace
      # Agregar parent
      parent = options[:parent] || self.options[:parent]
      parts << parent unless parent.blank?
      # Agregar controller
      parts << self.controller_name.singularize
      #
      parts << 'path'
      helper_name = parts.join('_')
      ids = [element.id]
      ids.unshift @parent.id unless parent.blank?
      send(helper_name, *ids)
    end

    def get_index
      path  = "#{controller_name}_path"
      unless options[:parent].blank?
        path << "(params[:#{options[:parent].to_s}_id])"
      end     
      eval(path)
    end
    
    def search_message(search_key)
      "se encontraron #{count_selected} resultados con \"<b>#{search_key}</b>\""
    end
    
    def get_resource
      @resource = model_class.find(params[:id])
    end   
    
    def model_name
      self.class.model_name
    end
    
    def model_class
      self.class.model_class
    end
    
    def options
      self.class.options
    end
    
    def parent_class
      self.class.parent_class
    end
    
    def parent_key
      options[:foreign_key] || "#{options[:parent]}_id".to_sym
    end
        
    def conditions_for(fields=[])
      predicate = []
      values    = []
      fields.each do |field|
        predicate << "lower(#{field.to_s}) like ?"
        values    << "'%' + @search_key.downcase + '%'"
      end
      eval("[\"#{predicate.join(' OR ')}\", #{values.join(',')}]")
    end
    
    def all
      set_filter_for nil, nil
    end
    
    protected

      def if_available(action)
        if self.class.accepted_action?(action)
          yield
        else
          raise ActionController::UnknownAction
        end
      end
    
      def count_selected
        model_class.count(:include => get_includes)
      end
      
      def save_model
        begin
          model_class.transaction do 
            before_save if respond_to?('before_save')
            if @success = @resource.save!
              after_save if respond_to?('after_save')
            end
          end 
        rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
          logger.error("Ocurrió una exception al salvar el registro: " + $!)
          @success = false
        end
      end
      
      def get_parent
        if parent = options[:parent]
          begin
            @parent = parent_class.find(params[:"#{parent}_id"])
          rescue ActiveRecord::RecordNotFound
            flash[:error] = "No existe el padre del elemento solicitado"
            redirect_to ''
            return false
          end
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
      
      def set_filter_for(name_space, condition)
        session[:c_filter] = name_space
        session["#{controller_name}"] = condition
        redirect_to :action => 'index' unless name_space.to_s == 'index'
      end
      
      def call_before_render
        before_render if respond_to?('before_render')
      end
      
  end
  
end
