module AdministrateMe::AdminScaffold

  module InstanceMethods
  
    def get_list    
      session[:mini] = ''
      @search_key = params[:search_key]
      model_class.with_scope(:find => {:conditions => global_scope}) do 
        model_class.with_scope(:find => {:conditions => search_scope}) do 
          @pages, @records = paginate(model_name, get_list_options) 
          set_search_message
        end
      end
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
    
    def global_scope
      gc = respond_to?('general_conditions') ? general_conditions : nil
      if gc
        gc.merge(session[:filters]) if session[:filters]  
      else
        gc = session[:filters] if session[:filters]  
      end
      gc
    end   
    
    def search_scope
      sc = @search_key.blank? ? nil : conditions_for(options[:search])
    end   
  
    def index 
      get_list
      respond_to do |format|
        format.html { render :template => 'commons/index' }
        format.xml  { render :xml => instance_variable_get("@#{controller_name}").to_xml }
      end
    end
    
    def search    
      get_list
      render :partial => 'list'    
    end
    
    def show
      unless options[:except] && options[:except].include?(:show)
        respond_to do |format|
          format.html # show.rhtml
          format.xml  { render :xml => eval("@#{controller_name.singularize}.to_xml") }      
        end
      else
        not_available
      end
    end
    
    def new    
      unless options[:except] && options[:except].include?(:new)
        instance_variable_set("@resource", eval("#{controller_name.singularize.capitalize}.new"))
        render :template => 'commons/new'
      else
        not_available
      end
    end
    
    def edit
      unless options[:except] && options[:except].include?(:edit)
        render :template => 'commons/edit'
      else
        not_available
      end
    end
    
    def create
      unless options[:except] && options[:except].include?(:new)
        create_params = params[model_name.to_sym]
        if parent = options[:parent]
          create_params[parent_key.to_sym] = @parent.id
        end
        @resource = model_class.new(create_params)
        save_model
    
        respond_to do |format|
          if @success
            flash[:notice] = 'El registro fue creado exitosamente'        
            format.html { redirect_to eval("#{model_name}_#{generate_url}") }
            format.xml  { head :created, :location => eval("#{controller_name.singularize}_url(@resource)") }
          else
            format.html { render :template => "commons/new" }
            format.xml  { render :xml => @resource.errors.to_xml }        
          end
        end
      else
        not_available
      end
    end
    
    def update 
      unless options[:except] && options[:except].include?(:edit)
        respond_to do |format|
          if @resource.update_attributes(params[model_name.to_sym])
            flash[:notice] = 'Las cambios fueron guardados exitosamente'
            format.html { redirect_to eval("#{model_name}_#{generate_url}") }
            format.xml  { head :ok }
          else
            format.html { render :template => "commons/edit" }        
            format.xml  { render :xml => @resource.errors.to_xml }
          end
        end
      else
        not_available
      end
    end
    
    def destroy
      unless options[:except] && options[:except].include?(:destroy)
        @resource.destroy
    
        respond_to do |format|
          flash[:notice] = 'El registro fue eliminado exitosamente.'
          format.html { redirect_to path_to_index }      
          format.xml  { head :ok }
        end
      else
        not_available
      end
    end
    
    def path_to_index
      path  = "#{controller_name}_path"
      unless options[:parent].blank?
        path << "(params[:#{options[:parent].to_s}_id])"
      end
      eval(path)
    end
    
    def path_to_resource(resource)
      path  = "#{controller_name.singularize}_path("
      unless options[:parent].blank?
        path << "params[:#{options[:parent].to_s}_id], "
      end
      path << "#{resource.to_param})"
      logger.info "path_to_resource: #{path}"
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
        values    << "@search_key.downcase + '%'"
      end
      eval("[\"#{predicate.join(' OR ')}\", #{values.join(',')}]")
    end
    
    def all
      set_filter_for nil, nil
    end
    
    protected
    
      def not_available
        flash[:error] = 'la transacción solicitada no se encuentra disponible'
        redirect_to :action => 'index'
      end
    
      def count_selected
        model_class.count
      end
      
      def save_model
        begin
          model_class.transaction do 
#            before_save
            if @success = @resource.save!
#              after_save
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
        session[:filters] = condition
        redirect_to :action => 'index'
      end
      
  end
  
end