module AdministrateMe
  
  module ClassMethods
  
    def administrate_me(options = {})
      @administrate_me_options = {}
      @administrate_me_options[:secured] = true
      yield
      
      build            
    end            
    
    def except(*actions)
      @administrate_me_options[:except] = actions
    end
    
    def search(*fields)
      @administrate_me_options[:search] = fields
    end
    
    def order(criteria)
      @administrate_me_options[:order_by] = criteria
    end
    
    def per_page(records)
      @administrate_me_options[:per_page] = records
    end
    
    def public_access!
      @administrate_me_options[:secured] = false
    end

    def set_parent(parent)
      @administrate_me_options[:empresa] = parent
    end
    
    def set_model(model)
      @administrate_me_options[:model] = model
    end
    
    def set_foreign_key(foreign_key)
      @administrate_me_options[:foreign_key] = foreign_key
    end
    
    def excel_available!
      @administrate_me_options[:excel] = true
    end
    
    def filters
      yield
    end
    
    def set(name, conditions)
      define_method(name) do
        set_filter_for(name, conditions)
      end
    end
        
    def build
      include AdministrateMe::AdminScaffold::InstanceMethods
      layout 'admin_layout'
      
      before_filter :get_resource, :only => [:show, :edit, :update, :destroy]
      before_filter :get_parent
      
      if respond_to?('tab')
        before_filter :tab
      end
      
      unless @administrate_me_options[:secured] == false
        before_filter :secured_access
      end
    end
    
    def model_name
      @administrate_me_options[:model] || to_s.gsub(/Controller$/, '').singularize.underscore
    end
    
    def model_class
      model_name.classify.constantize
    end
    
    def parent_class
      @administrate_me_options[:parent].to_s.classify.constantize
    end
    
    def options
      @administrate_me_options
    end
    
    def accepted_action(action)
      !options[:except] || !options[:except].include?(action)
    end
    
  end
  
end

ActionController::Base.extend AdministrateMe::ClassMethods