module AdministrateMe::AdminScaffold

  module InstanceMethods
  
    def index  
      respond_to do |format|
        format.html { render 'commons/index' }
        format.xml  { render :xml => eval("@#{controller_name}.to_xml") }
      end
    end
    
    def search    
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
      @resource = eval("#{controller_name.singularize.capitalize}.new(params[:#{controller_name.singularize.to_sym}])")
  
      respond_to do |format|
        if @resource.save
          flash[:notice] = 'El registro fue creado exitosamente'        
          format.html { redirect_to eval("#{controller_name.singularize}_url(@resource)") }
          format.xml  { head :created, :location => eval("#{controller_name.singularize}_url(@resource)") }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @resource.errors.to_xml }        
        end
      end
    end
    
    def update        
      respond_to do |format|
        if eval("@#{controller_name.singularize}.update_attributes(params[:#{controller_name.singularize}])")
          flash[:notice] = 'Las cambios fueron guardados exitosamente'
          format.html { redirect_to eval("#{controller_name.singularize}_url(@#{controller_name.singularize})") }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }        
          format.xml  { render :xml => eval("@#{controller_name.singularize}.errors.to_xml") }
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
    
    def searh_message(search_key, conditions)
      "la búsqueda de '#{search_key}' produjo #{count_selected(conditions)} resultados"
    end
    
    def get_resource    
      instance_variable_set("@#{controller_name.singularize}", eval("#{controller_name.singularize.capitalize}.find(params[:id])"))
    end
    
  end
  
end