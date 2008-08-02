# This module will extend the ActionController::Base class, its methods will be 
# available as class methods on all your application's controllers.
#
module AdministrateMeBase
  # Modules are the tabs that your administrate_me controller will display.
  # The +set_module+ method takes a +name+ and a +options+ hash as parameters 
  # and adds a new tab to the app. +name+ will only be used to further reference 
  # and must be unique for each module defined.
  # 
  # The options allows you to generate the default values that will be used. 
  # Valid options:
  # * <tt>:caption</tt> - A string with a label that will be used on the tab.
  # * <tt>:url</tt> - The url where the tab will link to.
  # By default the +caption+ will be the humanized +name+ of the module and the 
  # +url+ will link to the resource with the same name.
  # 
  # == Where to put modules definitions?
  # 
  # Modules can be defined at a class level or at an instance level. You have to
  # use class level modules definition when the definitions are static and the
  # same for each request on the controllers. If your tab have to be dynamic and 
  # different for each request you have to use instance level definitions. 
  # Let's see some examples.
  # 
  # === Class level definitions
  # 
  # In this case you can put your modules definitions directly on your 
  # application.rb file. The most simple scenario is this:
  # 
  #   class ApplicationController < ActionController::Base
  #     set_module :products
  #     set_module :customers
  #   end
  #   
  # If you're using namespaced controllers and you want different tabs on each 
  # namespace you can follow this scheme:
  # 
  #   # controllers/application.rb
  #   class ApplicationController < ActionController::Base
  #     set_module :products
  #   end
  #   
  #   # controllers/admin/core_admin.rb
  #   # All admin namespace controllers inherith from this class
  #   class CoreAdmin < ApplicationController
  #     set_module :users
  #     set_module :parameters
  #   end
  #   
  #   # controllers/user/core_user.rb
  #   # All user namespace controllers inherith from this class
  #   class CoreUser < ApplicationController
  #     set_module :customers
  #     set_module :transactions
  #   end
  #   
  # We have a base ApplicationController defining the +products+ tab, CoreAdmin
  # defines +users+ and +parameters+ so, any access to controllers
  # on this namespace will only display +products+, +users+ and 
  # +parameters+ tabs.
  # Any access to CoreUser administrate_me controllers will only display +products+,
  # +customers+ and +transactions+ tabs.
  #
  # === Request level definitions
  # 
  # Sometimes you will need to make your tabs dynamic depending on the data 
  # received on each request. In this case you will need to define your modules
  # on a per request basis. For this you have to use the +modules+ controller 
  # callback and call +set_module+ there as necessary.
  # 
  #   class ApplicationController < ActionController::Base
  #     set_module :products
  #     
  #     def modules
  #       set_module :parameters if current_user.is_admin?
  #     end
  #   end
  #   
  # In this case the +products+ tabs will be displayed on all requests and the
  # +parameters+ tab will only appear on the requests performed by the admin user.
  #
  def set_module(name, options = {})
    self.ame_modules ||= []
    self.ame_modules << administrate_me_compose_module(name, options)
  end

  def administrate_me_compose_module(name, options = {})
    {
      :name => name, 
      :caption => options[:caption] || name.to_s.humanize,
      :url => options[:url] || {:controller => name.to_s.pluralize}
    }
  end
end
