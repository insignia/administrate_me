# This is the pluing's core where all definitions are made.
# When you call the administrate_me class method on a controller all the 
# AdminScaffold methods are added to that controller. Basically this allows you
# to have a full featured table administration on that controller.
# 
# See README file to a step by step guide about how to setup an administrate_me
# application.
# 
# == Callbacks
# 
# There are several callbacks that can be added to you controller to handle 
# features on you app and extend the administrate_me ones.
# 
# ==== general_conditions
# 
# This method is expected to return a +conditions+ value that will be used to 
# narrow down the results of the +index+ action.
#  
# The controller method +get_list+ is in charge to return records for the +index+
# action, even if the request is a search request or an index filter. The +get_list+
# method will always use this general conditions using a +with_scope+ sentence
# to include them on the +find+ method call.
# 
# ==== before_render
# 
# This method will be called on the controller just before the respond_to block
# on every administrate_me action. It can be used to define some extra instance
# variables to use them on the views.
# 
# ==== before_save and after_save
# 
# This methods will be called and after the resource is saved. 
# Be careful about it's use, you should consider as first option to include this
# kind of logic on +before_save+ and +after_save+ callbacks of your model. 
# Just use them when they're really controller related.
# 
# == Search
# 
# [TODO]
# 
#
module AdministrateMe
  
  module ClassMethods
    
    class AdministrateMeConfig
      attr_accessor :options
      
      def initialize
        @options = {}
        @options[:except] = []
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
        @options[:scaffold] = false
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
        @options[:except] = actions
      end
      
      # Use search to indicate the fields to be looked up when the search action
      # is executed.
      # Note that the option includes was set up, the fields selected for search
      # should be specified with its table name, i.e.: 'products.name'.
      def search(*fields)
        @options[:search] = fields
      end
      
      # Use includes to indicate the associations that should be loaded when
      # find action is executed.
      #
      # ==== Example
      #   
      #   class ProductsController < ApplicationController
      #     administrate_me do
      #       includes 'brand'
      #       search   'brands.name', 'products.name', 'products.description'
      #       order    'brands.name', 'products,name'
      #     end
      #   end
      #    
      def includes(*tables)
        @options[:includes] = tables
      end
      
      def order(criteria)
        @options[:order_by] = criteria
      end
      
      # Use per_page to indicate the number of records to be listed per page.
      def per_page(records)
        @options[:per_page] = records
      end
      
      def set_parent(parent)
        @options[:parent] = parent
      end
      
      def set_model(model)
        @options[:model] = model
      end
      
      def set_foreign_key(foreign_key)
        @options[:foreign_key] = foreign_key
      end
      
      def excel_available!
        @options[:excel] = true
      end
    end
    
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
      self.extend AdministrateMe::ClassMethods::Base
      yield(config = AdministrateMeConfig.new)
      build config
    end            

    module Base
      
      def filters
        yield
      end
      
      def set(name, conditions)
        define_method(name) do
          set_filter_for(name, conditions)
        end
      end
          
      def build(config)
        instance_variable_set("@administrate_me_options", config.options)
        layout :set_layout
        
        unless config.options[:scaffold] == false
          include AdministrateMe::InstanceMethods
          include AdministrateMe::AdminScaffold::InstanceMethods
          hide_action :path_to_element
          before_filter :get_resource, :only => actions_for_get_resource
          before_filter :get_parent
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
      
      def namespace
        to_s =~ /(.*)::/
        $1 ? $1.underscore : nil
      end
      
      def model_name
        @administrate_me_options[:model] || to_s.gsub(/Controller$/, '').gsub(/.*::/, '').singularize.underscore
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
        options[:except].empty? || !options[:except].include?(translated_action)
      end
    end    
  end
  
  module InstanceMethods
    # El método set_module toma como parámetros el nombre de módulo a definir y 
    # opcionalmente un hash de opciones. El hash de opciones permite reemplazar 
    # los siguientes valores por defecto:
    #   :caption = Nombre a mostrar en la pestaña. Por defecto se toma el nombre
    #    del módulo en formato "humanized". 
    #   :url = Dirección del enlace en la pestaña. Por defecto se crea un
    #    enlace al index del controller con nombre igual al del módulo. 
    # Ej:
    #   set_module :productos, :caption => 'Articulos', :url => activos_productos_url()
    #
    def set_module(name, options = {})
      @instance_modules << self.class.administrate_me_compose_module(name, options)
    end
    
    def set_layout
      self.respond_to?('admin_layout') ? admin_layout : "admin_layout" 
    end
  end
  
end

