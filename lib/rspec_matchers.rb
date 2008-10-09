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
      #       ProductsController.should be_searchable_by(:name)
      #     end
      #   end
      #
      def be_ordered_by(field)
        simple_matcher("controller to be ordered by '#{field}' field") do |controller_class|
          controller.class.options[:order_by] == field
        end
      end

    end
  end
end
