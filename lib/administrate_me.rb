module AdministrateMe
  
  module ClassMethods
    def administrate_me(options = {})
      @administrate_me_options = options
      include AdministrateMe::AdminScaffold::InstanceMethods
      layout 'admin_layout'
      before_filter :get_resource, :only => [:show, :edit, :update, :destroy]
    end
    
    def model_name
      @administrate_me_options[:model] || to_s.gsub(/Controller$/, '').singularize.underscore
    end
    
    def model_class
      model_name.classify.constantize
    end

  end
  
end

ActionController::Base.extend AdministrateMe::ClassMethods