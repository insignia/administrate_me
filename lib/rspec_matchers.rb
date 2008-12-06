module Spec
  module Rails
    module Matchers

      # Validates that a controller using administrate_me has set the search option for a given field.
      #
      # == Example:
      #
      # On the controller:
      #
      #   class ProductsController < ApplicationController
      #     administrate_me do |a|
      #       a.search :name, :brand
      #     end
      #   end
      #
      # On the controller specs:
      #
      #   describe ProductsController do
      #     it "should be searchable by name" do
      #       ProductsController.should be_searchable_by(:name)
      #     end
      #
      #     it "should be searchable by brand" do
      #       ProductsController.should be_searchable_by(:brand)
      #     end
      #   end
      #
      def be_searchable_by(field)
        simple_matcher("controller to be sortable by '#{field}' field") do |controller_class|
          controller_class.options[:search].include?(field)
        end
      end

      # Validates that a controller using administrate_me has set the order the returned records.
      #
      # == Example:
      #
      # On the controller:
      #
      #   class ProductsController < ApplicationController
      #     administrate_me do |a|
      #       a.order :name
      #     end
      #   end
      #
      # On the controller specs:
      #
      #   describe ProductsController do
      #     it "should be ordered by name" do
      #       ProductsController.should be_ordered_by(:name)
      #     end
      #   end
      #
      def be_ordered_by(field)
        simple_matcher("controller to be ordered by '#{field}' field") do |controller_class|
          controller.class.options[:order_by] == field
        end
      end
      
      # Validates that a controller using administrate_me has set a nested relation with
      # another controller.
      #
      # == Example:
      #
      # On the controller:
      #
      #   class ProductsController < ApplicationController
      #     administrate_me do |a|
      #       a.belongs_to :brand
      #     end
      #   end
      #
      # On the controller specs:
      #
      #   describe ProductsController do
      #     it "should be a child of brand" do
      #       ProductsController.should be_a_child_of(:brand)
      #     end
      #   end
      #
      def be_a_child_of(parent)
        simple_matcher("controller to be a child of '#{parent}'") do |controller_class|
          controller.class.options[:parent] == parent
        end
      end
      
      # Validates that a controller using administrate_me has customized form settings
      #
      # == Example:
      #
      # On the controller:
      #
      #   class ProductsController < ApplicationController
      #     administrate_me do |a|
      #       a.belongs_to :brand
      #     end
      #
      #     def form_settings
      #       { :multipart => true }
      #     end
      #   end
      #
      # On the controller specs:
      #
      #   describe ProductsController do
      #     it "should have customized form settings" do
      #       ProductsController.should have_customized_form_settings_with({ :multipart => true })
      #     end
      #   end
      #
      def have_customized_form_settings_with(settings)
        simple_matcher("controller have customized form settings with '#{settings}'") do |controller_class|
          controller.should respond_to(:form_settings)
          controller.form_settings.should == settings
        end
      end

      # Validates that a controller using administrate_me sets an specific tab name
      def use_tab(tab_name)
        simple_matcher("controller use the tab name '#{tab_name}'") do |controller_class|
          controller.class.options[:tab] == tab_name
        end
      end

    end
  end
end
