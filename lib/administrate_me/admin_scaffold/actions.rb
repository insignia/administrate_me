module AdministrateMe
  module AdminScaffold
    module Actions
      def index
        get_list
        call_before_render
        unless performed?
          # Fix for an ugly IE6/7 bug
          # http://geminstallthat.wordpress.com/2008/05/14/ie6-accept-header-is-faulty/
          # The bug is described there and the fix I choose on comment #5.
          request.format = :html if request.env['HTTP_USER_AGENT'] =~ /msie/i && (request.format.to_s =~ /(text|html|xml|js|application\/vnd\.ms-excel|\*)/).nil?
          @is_xls = request.format.xls?
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
          associate_resource_to_parent
          @resource = model_class.new(params[model_name.to_sym])
          save_model
          call_before_render
          unless performed?
            respond_to do |format|
              if @success
                flash[:notice] = I18n.t('messages.create_success')
                session["#{controller_name}_search_key"] = nil
                format.html { redirect_to smart_path }
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
                format.html { redirect_to smart_path(@resource) }
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
                format.html { redirect_to smart_path }
                format.xml  { head :ok }
              else
                format.html { render :template => "commons/base_form" }
                format.xml  { head :error }
              end
            end
          end
        end
      end
    end
  end
end

