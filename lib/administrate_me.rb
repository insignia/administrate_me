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
# ==== admin_style
#
# This callback will be called if defined to override the stylesheets included
# on the pages.
#
#   def admin_style
#     ['admin_look', 'my-css']
#   end
#
# This will include de default admin_look.css file and will add the custom my-css.css
# file to all templates.
# Is can be specified on application.rb or in any particular controller.
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
      #     administrate_me do |a|
      #       a.no_scaffold!
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
      #     administrate_me do |a|
      #       a.search :name, :description, :price
      #       a.except :new, :edit, :destroy
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
      #     administrate_me do |a|
      #       a.includes 'brand'
      #       a.search   'brands.name', 'products.name', 'products.description'
      #       a.order    'brands.name, products.name'
      #     end
      #   end
      #    
      def includes(*tables)
        @options[:includes] = tables
      end
      
      # Allows to specify the sort criteria on the retrieved records. It has to
      # have the same format of the :sort value on the ActiveRecord::Base.find() options.
      def order(criteria)
        @options[:order_by] = criteria
      end
      
      # Use per_page to indicate the number of records to be listed per page.
      # To set the number of records per page administrate_me uses this priorities:
      # - per_page setting on the controller
      # - per_page class method on the model
      # - a default of 15 records per page.
      #
      # ==== Example
      #
      #   class ProductsController < ApplicationController
      #     administrate_me do |a|
      #       a.per_page 15
      #     end
      #   end
      #
      def per_page(records)
        @options[:per_page] = records
      end
      
      # Used to specity the parent resource of the current resource.
      # 
      # basic usage:
      #
      #   administrate_me do |a|
      #     a.set_parent :branch
      #   end
      #
      # usage with an specific foreign key
      # 
      #   administrate_me do |a|
      #     a.set_parent :branch, :foreign_key => 'a01_branch'
      #   end
      #
      # or you can specify the relation in a more "rails way", like this:
      #
      #   administrate_me do |a|
      #     a.belongs_to :branch
      #   end
      #
      def set_parent(parent,options={})
        @options[:parent] = parent
        @options[:foreign_key] = options[:foreign_key] if options[:foreign_key]
      end
      alias_method "belongs_to", "set_parent"
      
      #
      #  AdministrateMe supports the HABTM associations of a given resource.
      #
      #  Usage:
      #
      #   In the controller definition: 
      #
      #   administrate_me do |a|
      #     a.has_and_belongs_to_many :tags
      #   end
      #
      #   In the _form partial definition: 
      #
      #   <%= f.has_and_belongs_to_many :tags %>
      #
      #  This feature is inspired by Ryan Bates' railscasts.com
      #  http://railscasts.com/episodes/17-habtm-checkboxes
      #
      def has_and_belongs_to_many(*habtms)
        @options[:habtms] = habtms
      end

      # Handy and improved autocomplete for forms.
      #
      # ==== Example
      #
      # The model you're administrating:
      #
      #   class Account < ActiveRecord::Base
      #     belongs_to :person
      #   end
      #
      # In the controller definition
      #
      #   class AccountController < ApplicationController
      #     administrate_me do |a|
      #       a.auto_complete_for :person, [:first_name, :last_name]
      #     end
      #   end
      #
      # On the _form.html.erb
      #
      #   <%= f.auto_complete :person, [:first_name, :last_name]
      #
      # This will create a text_field_with_auto_complete that will be able
      # to correctly to inform the selected record.
      #
      # A controller action named <code>auto_complete_for_person_first_name_and_last_name</code>
      # will be created on the controller that will search on the People model using first_name
      # and last_name fields. On the form, javascript will be used to not only store
      # the description of the record on the text field as the regular auto_complete does,
      # but it will also store the record's id on a hidden field.
      # This hidden data will allow the correct record to be associated to the
      # edited instance.
      #
      def auto_complete_for(association, fields, options = {})
        (@options[:auto_complete_for] ||= []) << [association, fields, options]
      end
      
      # Used to specify the model name of the resource this controller handles. 
      # It's optional and it has to be used only when the model name is different from 
      # the controller name.
      def set_model(model)
        @options[:model] = model
      end
      
      # Used to specify foreign_key to refer to the parent record. By default parent
      # name plus "_id" will be used to access and assign the parent record.
      # 
      # ==== Example
      # 
      #   class AccountController < ApplicationController
      #     administrate_me do |a|
      #       a.set_parent :user
      #       a.set_foreign_key :owner_id
      #     end
      #   end
      #   
      def set_foreign_key(foreign_key)
        @options[:foreign_key] = foreign_key
      end
      
      def excel_available!
        @options[:excel] = true
      end

      class Filter
        attr_accessor :name, :conditions, :options

        def name=(value)
          @name = value.to_s
        end

        def label
          (self.options && self.options[:label]) || self.name.humanize
        end
      end

      class ComboFilter < Filter
        attr_accessor :block

        def options_for_select
          [[self.options[:all] || 'No filtrar', nil]] + stringyfied_options
        end

        def conditions(value)
          {self.name.to_s => value}
        end

        protected 
        
        def stringyfied_options
          opts = self.block.call
          opts.first.is_a?(Array) ? opts.map{|e| [e.first, e.last.to_s]} : opts
        end

      end

      class FilterConfig
        attr_accessor :filters
        attr_accessor :combos

        def initialize
          @filters = []
          @combos  = []
        end

        def filter_by_name(filter_name)
          (@filters + @combos).find {|f| f.name == filter_name.to_s}
        end

        def conditions_for_filter(filter_name)
          filter = filter_by_name(filter_name)
          filter ? filter.conditions : conditions_for_dynamic_filter(filter_name)
        end

        def conditions_for_dynamic_filter(filter_name)
          @dynamic_filter.call(filter_name) if @dynamic_filter
        end

        def set(name, conditions)
          filter = Filter.new
          filter.name = name
          filter.conditions = conditions
          @filters << filter
        end

        def dynamic(&block)
          @dynamic_filter = block
        end

        def combo(name, options = {}, &block)
          filter = ComboFilter.new
          filter.name = name
          filter.options = options
          filter.block = block
          @combos << filter
        end

        def all_filters
          @filters + @combos
        end

        def is_combo?(filter_name)
          !!@combos.find{|filter| filter.name == filter_name.to_s}
        end

      end

      # Setting automatic filters. One example is better than one thousand words.
      #
      # === Example:
      #
      #   administrate_me do |a|
      #     a.filters do |f|
      #       # Assigning a name and a search condition to each filter.
      #       f.set :active,   {:status => 'active'}
      #       f.set :inactive, "active <> 'active'"
      #     end
      #   end
      #
      # Then on your _list.html.erb file you just use this helpers to show the
      # filter links:
      #
      #   <% content_for :extras do %>
      #     <% filters_for do %>
      #       <%= filter_by 'All' %>
      #       <%= filter_by 'Active records', :active %>
      #       <%= filter_by 'Inactive records', :inactive %>
      #     <% end %>
      #   <% end %>
      #
      # You can also use this simplified form:
      #
      #   <% content_for :extras do %>
      #     <% filters_for do %>
      #       <%= all_filters %>
      #     <% end %>
      #   <% end %>
      #
      # Using a filter is just a matter of calling the index action on the
      # controller using a filter parameter. So something like this would work
      # too:
      #
      #   <%= link_to 'Active records', users_path(:filter => 'active') %>
      #
      # === Combo filters
      #
      # You can also add multiple combo filters on each controller. This will
      # filters will add conditions that will be added to the regular ones.
      # Having multiple combo filters will allow you apply multiple conditions
      # on the same dataset.
      #
      #   class ProductsController < ApplicationController
      #   administrate_me do |a|
      #     f.combo :brand_id do
      #       Brand.all.map{|b| [b.name, b.id]}
      #     end
      #     # In case you have the to_select plugin installed you can do this
      #     f.combo :category_id do
      #       Category.to_select
      #     end
      #     # Also using a simple list of values
      #     f.combo :state do
      #       ['active', 'deleted']
      #     end
      #   end
      #
      # See http://github.com/insignia/to_select or similar hacks will be very
      # useful defining this combo filters.
      #
      # === Dynamic filters
      #
      # You can also set dynamic filters. This way, you can create a condition
      # to be used depending the filter parameter received on the request:
      #
      #   administrate_me do |a|
      #     a.filters do |f|
      #       # Assigning a name and a search condition to each filter.
      #       f.set :active,   {:status => 'active'}
      #       f.set :inactive, "active <> 'active'"
      #
      #       f.dynamic do |filter_name|
      #         # Create a find condition based on the received filter paramter.
      #         if filter_name =~ ROLE_FILTER_RE
      #           "roles.name = '#{$1}'"
      #         end
      #       end
      #     end
      #   end
      #
      # Then on the view:
      #
      #   <% content_for :extras do %>
      #     <% filters_for do %>
      #       <%= all_filters %>
      #       <% @roles.each do |role| %>
      #         <%= filter_by role.name, "role_#{role.name}"  %>
      #       <% end %>
      #     <% end %>
      #   <% end %>
      #
      def filters
        filter_config = FilterConfig.new
        yield filter_config
        @options[:filter_config] = filter_config
      end

    end
    
    # Use this macro to include all the necesary methods that a controller
    # needs to support a Restfull administration of an specific resource.
    #
    # ==== Example
    #   
    #   class ProductsController < ApplicationController
    #     administrate_me do |a|
    #       a.search :name, :description, :price
    #       a.order  'name'
    #     end
    #   end
    # 
    # You'll need to add map.resources :products to the routes.rb file.
    def administrate_me(options = {})
      self.extend AdministrateMe::ClassMethods::Base
      config = AdministrateMeConfig.new
      yield(config) if block_given?
      build config
    end            

    module Base
      
      def build(config)
        instance_variable_set("@administrate_me_options", config.options)
        layout :set_layout
        
        unless config.options[:scaffold] == false
          include AdministrateMe::InstanceMethods
          include AdministrateMe::AdminScaffold::InstanceMethods
          hide_action   :path_to_element
          before_filter :set_active_filter
          before_filter :get_resource, :only => actions_for_get_resource
          before_filter :get_parent

          if options[:habtms]
            before_filter :habtm_callback, :only => "update"
          end

          (options[:auto_complete_for] || []).each do |auto_complete_for|
            administrate_me_auto_complete_for(*auto_complete_for)
          end
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

      # Improved text_field_with_auto_complete for administrate_me.
      # See AdministrateMeConfig#auto_complete_for
      def administrate_me_auto_complete_for(association, fields, options = {})
        fields = [*fields]
        method_suffix = fields.map(&:to_s).join('_and_')
        define_method("auto_complete_for_#{association}_#{method_suffix}") do
          like = fields.map {|m| "LOWER(#{m}) LIKE ?"}.join(' OR ')
          conditions = [like]
          conditions << fields.map {|m| '%' + params[association][method_suffix].to_s.downcase + '%'}
          model = (options.delete(:model) || association)
          model_class = model.to_s.camelize.constantize
          extra_conditions = options.delete(:conditions)
          # search conditions
          find_options = {
            :conditions => conditions.flatten,
            :order => "#{fields.first} ASC",
            :limit => 10 }.merge!(options)
          # Additional conditions received as a parameter
          model_class.send(:with_scope, :find => {:conditions => extra_conditions}) do
            @items = model_class.find(:all, find_options)
          end
          @methods = fields
          render :inline => <<-erb_end
            <ul>
              <% for item in @items %>
                <li id="<%= "#{association}_auto_complete_id_" + item.id.to_s %>"><%= @methods.map {|m| item.send(m)}.join(' - ') %></li>
              <% end %>
            </ul>
          erb_end
        end
      end
    end
  end
  
  module InstanceMethods
    # Adds a module in a request level basis.
    # See <code>AdministrateMeBase::set_module</code> for further information
    # about modules.
    def set_module(name, options = {})
      @instance_modules << self.class.administrate_me_compose_module(name, options)
    end
    
    def set_layout
      self.respond_to?('admin_layout') ? admin_layout : "admin_layout" 
    end
  end
  
end

