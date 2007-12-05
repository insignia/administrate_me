module AdministrateMe
  
  module ClassMethods
    # Use this macro to include all the necesary methods that a controller
    # needs to support a Restfull administration of an specific resource.
    #
    # ==== Example
    #   
    #   class ProductsController < ApplicationController
    #     administrate_me do
    #       search :name, :description, :price
    #       order  'name'
    #     end
    #   end
    # 
    # You'll need to add map.resources :products to the routes.rb file.
    def administrate_me(options = {})
      @administrate_me_options = {}
      @administrate_me_options[:secured] = true
      yield
      
      build            
    end            
    
    def set_module(name, options = {})
      self.ame_modules ||= []
      self.ame_modules << compose_module(name, options)
    end
    
    def compose_module(name, options = {})
      {
        :name => name, 
        :caption => options[:caption] || name.to_s.humanize,
        :url => options[:url] || {:controller => "#{name.to_s.pluralize}"}
      }
    end
    
    # Sometimes it's necesary to include controllers in the application
    # which don't need to include all Restful actions. In this particular
    # case, you can specify this in the plugin macro with the options
    # 'no_scaffold!'.
    # 
    #   class DashboardController < ApplicationController
    #     administrate_me do
    #       no_scaffold!
    #     end
    #   end
    # 
    # In this case, the controller Dashboard loads the basic features of 
    # the plugin, but does not include the Restful methods.
    def no_scaffold!
      @administrate_me_options[:scaffold] = false
    end
    
    # The except method specifies the action that will not be allowed
    # in the controller.
    #
    # ==== Example
    #   
    #   class ProductsController < ApplicationController
    #     administrate_me do
    #       search :name, :description, :price
    #       except :new, :edit, :destroy
    #     end
    #   end
    # 
    # With this configuration, the plugin load a read-only controller, that will only
    # accept the index and the show actions.
    def except(*actions)
      @administrate_me_options[:except] = actions
    end
    
    def search(*fields)
      @administrate_me_options[:search] = fields
    end
    
    def order(criteria)
      @administrate_me_options[:order_by] = criteria
    end
    
    # Use per_page to indicates the number of records to be listed per page.
    def per_page(records)
      @administrate_me_options[:per_page] = records
    end
    
    # The public_access! method specifies that the controller will not require user
    # authetication.
    def public_access!
      @administrate_me_options[:secured] = false
    end

    def set_parent(parent)
      @administrate_me_options[:parent] = parent
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
      layout :set_layout            
      
      unless @administrate_me_options[:scaffold] == false
        include AdministrateMe::AdminScaffold::InstanceMethods
        before_filter :get_resource, :only => actions_for_get_resource
        before_filter :get_parent
      end
      
      unless @administrate_me_options[:secured] == false
        before_filter :secured_access
      end            
      
      if respond_to?('tab')
        before_filter :tab
      end            
    end        
    
    def actions_for_get_resource
      list = []
      list << :edit    if accepted_action?(:edit)
      list << :update  if accepted_action?(:edit)
      list << :show    if accepted_action?(:show)
      list << :destroy if accepted_action?(:destroy)
      list
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
    
    def accepted_action?(action)
      translated_action = case action
      when :update
        :edit
      when :create
        :new
      else
        action
      end
      !options[:except] || !options[:except].include?(translated_action)
    end
    
  end
  
  module InstanceMethods
    def set_module(name, options = {})
      @instance_modules << self.class.compose_module(name, options)
    end
    
    def set_layout
      self.respond_to?('admin_layout') ? admin_layout : "admin_layout" 
    end
  end
  
end

ActionController::Base.extend AdministrateMe::ClassMethods
ActionController::Base.send :include, AdministrateMe::InstanceMethods
class ActionController::Base
  superclass_delegating_accessor :ame_modules
end
