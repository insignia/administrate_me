module AdministrateMe
  
  module ClassMethods
  
    def administrate_me(options = {})
      @administrate_me_options = options
      include AdministrateMe::AdminScaffold::InstanceMethods
      layout 'admin_layout'
      before_filter :get_resource, :only => [:show, :edit, :update, :destroy]
      before_filter :get_parent
      
      if respond_to?('tab')
        before_filter :tab
      end
      
      unless options[:secured] == false
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
    
  end
  
end

ActionController::Base.extend AdministrateMe::ClassMethods