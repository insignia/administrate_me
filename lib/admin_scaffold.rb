module AdministrateMe::AdminScaffold

  module InstanceMethods
  
    def get_list    
      session[:mini] = ''
      options = {:per_page => 15}
      @search_key = params[:search_key]
      gcond, scond = get_conditions
      model_class.with_scope(:find => {:conditions => gcond}) do 
        model_class.with_scope(:find => {:conditions => scond}) do 
          @pages, @records = paginate(model_name, options) 
          set_search_message
        end
      end
    end  
    
    def set_search_message
      unless params[:search_key].blank?        
        session[:mini] = search_message(@search_key) 
      end
    end
    
    def get_conditions
      gc = respond_to?('general_conditions') ? general_conditions : nil
      sc = @search_key.blank? ? nil : search_conditions
      [gc, sc]
    end
  
    def index 
      get_list
      respond_to do |format|
        format.html { render 'commons/index' }
        format.xml  { render :xml => instance_variable_get("@#{controller_name}").to_xml }
      end
    end
    
    def search    
      get_list
      render :partial => 'list'    
    end
    
    def show        
      respond_to do |format|
        format.html # show.rhtml
        format.xml  { render :xml => eval("@#{controller_name.singularize}.to_xml") }
      end
    end
    
    def new    
      instance_variable_set("@#{controller_name.singularize}", eval("#{controller_name.singularize.capitalize}.new"))
      render 'commons/new'
    end
    
    def edit
      render 'commons/edit'
    end
    
    def create
      @resource = model_class.new(params[model_name.to_sym])      
      if parent = options[:parent]
        @resource.send("#{parent_key}=", @parent.id)
      end
      save_model
  
      respond_to do |format|
        if @success
          flash[:notice] = 'El registro fue creado exitosamente'        
          format.html { redirect_to eval("#{controller_name.singularize}_url(@resource)") }
          format.xml  { head :created, :location => eval("#{controller_name.singularize}_url(@resource)") }
        else
          format.html { render "commons/new" }
          format.xml  { render :xml => @resource.errors.to_xml }        
        end
      end
    end
    
    def update        
      respond_to do |format|
        if @resource.update_attributes(params[model_name.to_sym])
          flash[:notice] = 'Las cambios fueron guardados exitosamente'
          format.html { redirect_to eval("#{model_name}_url(@resource)") }
          format.xml  { head :ok }
        else
          format.html { render "commons/edit" }        
          format.xml  { render :xml => @resource.errors.to_xml }
        end
      end
    end
    
    def destroy
      eval("@#{controller_name.singularize}.destroy")
  
      respond_to do |format|
        format.html { redirect_to eval("#{controller_name}_url") }      
        format.xml  { head :ok }
      end
    end
    
    def search_message(search_key)
      "la búsqueda de '#{search_key}' produjo #{count_selected} resultados"
    end
    
    def get_resource
      @resource = model_class.find(params[:id])
      logger.info "resource: #{@resource}"
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
    
    protected
    
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
      
    
  end
  
end