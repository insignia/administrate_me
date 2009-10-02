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
# You can perform a render or redirect on this callbacks to override the default
# administrate_me behaviour for the restful actions.
#
# There are also specific before_render callbacks that are called before render
# on specific actions. This actions will also be called before rendering it's
# the respective action:
#
#   before_render_new
#   before_render_create
#   before_render_edit
#   before_render_update
#   before_render_index
#   before_render_show
#   before_render_destroy
#
# This methods will be called on any of the metioned actions.
# <code>before_render_new_and_create</code> will be called on new and create actions and
# <code>before_render_edit_and_update</code> will be called on edit and update actions.
# They can be useful to prefill some values on instance variables on new or edit forms respectively.
#
# Also a <code>before_render_with_form</code> method will be called on new, create, edit
# and update actions. This is useful for prefilling values that will be needed on any action
# that includes a form.
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
      alias_method 'without_scaffold!', 'no_scaffold!'

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
      #
      # It can also use a block to tell when an action will be allowed.
      #
      #   class ProductsController < ApplicationController
      #     administrate_me do |a|
      #       a.search :name, :description, :price
      #       a.except :show do |method|
      #         if method == :new
      #           current_user.has_role('admin')
      #         else
      #           true
      #         end
      #       end
      #     end
      #   end
      #
      # The block should return true for the action to be allowed. Keep in mind
      # that you can combine parameters and the block to filter actions. In the
      # previous example the show action won't be available in any case, the new
      # action will be available only when the current user is an admin and
      # all the other action will always be available.
      #
      def except(*actions)
        @options[:except] = actions
        @options[:except_block] = proc if block_given?
      end

      # Use search to indicate the fields to be looked up when the search action
      # is executed.
      # Note that when the option <code>includes</code> was set up, the fields
      # included on <code>search</code> should be specified with its table name,
      # i.e.:
      #
      #   search 'products.name'
      #
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
      # you can also specify the name of the field to be render in the context
      # breadcrumb:
      #
      #   administrate_me do |a|
      #     a.belongs_to :branch, :context => :name
      #   end
      #
      # In case a controller is nested to a controller specity with set_model
      # option:
      #
      # for instance, if you have this definition:
      #
      #   map.resources :folder, :has_many => :products
      #
      # And that folder controller is setup for using branch model.
      #
      # You can use:
      #
      #   administrate_me do |a|
      #     a.belongs_to :branch, :context => :name, :as => :folder
      #   end
      #
      def set_parent(parent,options={})
        @options[:parent]      = parent
        @options[:foreign_key] = options[:foreign_key] if options[:foreign_key]
        @options[:context]     = options[:context]     if options[:context]
        @options[:as]          = options[:as]          if options[:as]
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
      #   <%= f.has_and_belongs_to_many :tags, :name, Tag.all %>
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

      # Used to specify exactly which tab will be lit on the current controller.
      # This is supposed to be used only when the tab name cant be detected automatically.
      # administrate_me provides several ways to set the current module/tab.
      #
      #   - tab() callback on the controller: Defining a <code>tab()</code> method on the controller that returns the name of the tab to turn on.
      #   - The tab keyword: This will set a static tab name to be set as active on the current controller.
      #   - The parent name of the controller: For controllers using set_parent or belongs_to, the current tab name will be guessed using the parent name.
      #   - The current controller name.
      #
      # ==== Example
      #
      #   class AccountController < ApplicationController
      #     administrate_me do |a|
      #       a.tab :listing
      #     end
      #   end
      #
      # On this example, the tab with the 'listing' name will be marked as current on the screen.
      #
      def tab(tab_name)
        @options[:tab] = tab_name
      end

      def excel_available!
        @options[:excel] = true
      end

      class Filter
        attr_accessor :name, :scope, :options

        def name=(value)
          @name = value.to_s
        end

        def label
          (self.options && self.options[:label]) || self.name.humanize
        end

        def get_scope(controller, value = nil)
          if Proc === scope
            controller.instance_eval(&scope)
          else
            scope
          end
        end

        def enabled?(controller)
          !(self.options && self.options[:if] && !controller.instance_eval(&self.options[:if]))
        end

      end

      class ComboFilter < Filter
        attr_accessor :block

        def options_for_select(controller)
          if options = stringyfied_options(controller)
            [[self.options[:all] || I18n.t('no_filter'), nil]] + options
          end
        end

        def get_scope(controller, value)
          if self.scope
            controller.instance_exec(value, &scope)
          elsif value
            {:conditions => {self.name.to_s => value}}
          end
        end

        protected

        def stringyfied_options(controller)
          if opts = controller.instance_eval(&self.block)
            opts.first.is_a?(Array) ? opts.map{|e| [e.first, e.last.to_s]} : opts
          end
        end

      end

      class FilterConfig
        attr_accessor :filters
        attr_accessor :combos

        def initialize
          @filters = []
          @combos  = []
        end

        def filter_by_name(controller, filter_name)
          filter = (@filters + @combos).find {|f| f.name == filter_name.to_s}
          filter && filter.enabled?(controller) ? filter : nil
        end

        def options_for_filter(controller, filter_name, value = nil)
          filter = filter_by_name(controller, filter_name)
          filter ? filter.get_scope(controller, value) : nil
        end

        def set(name, scope, options = {})
          filter = Filter.new
          filter.name = name
          filter.scope = scope
          filter.options = options
          @filters << filter
        end

        def combo(name, *args, &block)
          options = args.last.is_a?(Hash) ? args.pop : {}
          scope = args.first
          filter = ComboFilter.new
          filter.name = name
          filter.scope = scope
          filter.options = options
          filter.block = block
          @combos << filter
        end

        def all_filters(controller)
          (@filters + @combos).select {|filter| filter.enabled?(controller)}
        end

        def is_combo?(controller, filter_name)
          filter = @combos.find{|f| f.name == filter_name.to_s}
          filter && filter.enabled?(controller)
        end

      end

      # Setting automatic filters. One example is better than one thousand words.
      #
      # === Example:
      #
      #   administrate_me do |a|
      #     a.filters do |f|
      #       # Assigning a name and a search condition to each filter.
      #       f.set :active,   :conditions => {:status => 'active'}
      #       f.set :inactive, :conditions => "status <> 'active'"
      #       # A block can also be used an expresion that will be evaluated at runtime
      #       f.set :my_items, lambda { {:conditions => {:owner_id => current_user.id}} }
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
      # You can also add multiple combo filters on each controller. This
      # filters will add conditions that will be added to the regular ones.
      # Having multiple combo filters will allow you apply multiple conditions
      # on the same dataset at the same time.
      #
      # Each combo call should receive a block that will be evaluated on the
      # controller instance to get the options that will be available on the combo.
      # The search conditions will be applied using the combo name (the first parameter)
      # as a field name with the selected value.
      #
      #   class ProductsController < ApplicationController
      #     administrate_me do |a|
      #       a.filters do |f|
      #         f.combo :brand_id do
      #           Brand.all.map{|b| [b.name, b.id]}
      #         end
      #         # In case you have the to_select plugin installed you can do this
      #         f.combo :category_id do
      #           Category.to_select
      #         end
      #         # Also using a simple list of values
      #         f.combo(:state) {['active', 'deleted']}
      #       end
      #     end
      #   end
      #
      # You can also add a lambda as a second parameter to use more elaborate
      # conditions
      #
      #   class PeopleController < ApplicationController
      #     administrate_me do |a|
      #       a.filters do |f|
      #         # Some more complex combo filters
      #         f.combo :new_brand, lambda {|value| {:conditions => {'brands.new' => value}}, :include => :brand } do
      #           [['New', 1], ['Old', 0]]
      #         end
      #         # Given that the code blocks are avaluated on the controller instance context,
      #         # you can use controller methods to get runtime info, such as the current user
      #         # or maybe request paramters.
      #         f.combo :favorite_categories, lambda {|value| {:conditions => {:category_id => value}} do
      #           current_user.favorite_categories.map {|fc| [fc.name, fc.id]}
      #         end
      #     end
      #   end
      #
      # Using http://github.com/insignia/to_select or similar hacks/plugins will be very
      # useful defining this combo filters.
      #
      # === Conditional filters
      #
      # You can use an :if option to conditionally enable or disable a filter in a per
      # request basis.
      #
      #   class ProductsController < ApplicationController
      #     administrate_me do |a|
      #       a.filters do |f|
      #         f.set :active, {:conditions => "status = 'active'"}, :if => lambda { current_user.has_role?('admin') }
      #         f.combo :state, :if => lambda { current_user.has_role?('admin') } do
      #           ['active', 'deleted']
      #         end
      #       end
      #     end
      #   end
      #
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
          before_filter :set_active_filter
          before_filter :get_resource
          before_filter :get_parent

          if options[:habtms]
            before_filter :habtm_callback, :only => ['update', 'create']
          end

          (options[:auto_complete_for] || []).each do |auto_complete_for|
            administrate_me_auto_complete_for(*auto_complete_for)
          end
        end

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

    def options
      self.class.options
    end
  end

end

