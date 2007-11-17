module AdministrateMe
  
  module ClassMethods
    def administrate_me
      include AdministrateMe::AdminScaffold::InstanceMethods
      layout 'admin_layout'            
      before_filter :get_resource, :only => [:show, :edit, :update, :destroy]
      before_filter :get_list,     :only => [:index, :search]      
    end
  end
  
end

ActionController::Base.extend AdministrateMe::ClassMethods