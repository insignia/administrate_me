module AdminView
  # This module contains the list_builder_for helper and the helper methods it uses.
  module PresentationBuilder
    # This class holds list_builder_for information to render a grid.
    # It basically uses method_missing to add columns named the same as the method
    # calls received.
    # If you happen to use columns in your models named the same as its few public
    # methods (like gpb_columns and gpb_data) err... there would be some problems.
    class GridPresentationBuilder
      class ListColumn
        def initialize(field, options={})
          @field = field
          @options = options
        end

        def value_for(item, template)
          if @options[:with]
            related_value_for(item.send(@field))
          else
            item.send(@field)
          end
        end

        def related_value_for(value)
          if value.is_a?(Array)
            rtn = value.map{|x| safe_send(x, @options[:with])}.join(", ")
          else
            rtn = safe_send(value, @options[:with])
          end
          rtn
        end

        def caption
          @options[:caption] || @field.to_s.titleize
        end

        def style
          customizations = []
          customizations << "width:#{@options[:width]}"      if @options[:width]
          customizations << "color:#{@options[:color]}"      if @options[:color]
          customizations << "font-weight:bold"               if @options[:strong]
          customizations << "text-align:#{@options[:align]}" if @options[:align]
          customizations <<  @options[:style] if @options[:style]
          customizations.join(';')
        end

        private

        def safe_send(object, method)
          [*method].each do |m|
            object = object && object.respond_to?(m) ? object.send(m) : nil
          end
          object
        end

      end

      # This class handles the special case for columns that are resolved calling a
      # block to generate html.
      class ProcColumn < ListColumn
        def value_for(item, template)
          @field.call(item)
        end
      end

      # This class handles the special case for columns that are resolved calling a
      # helper with a field value as a parameter.
      class HelperColumn < ListColumn
        def initialize(helper_method, field, options={})
          @helper_method = helper_method
          super(field, options)
        end

        def value_for(item, template)
          template.send(@helper_method, item.send(@field))
        end
      end

      def initialize(collection)
        @collection = collection
        @columns = []
        @rows    = []
        @captions = {}
      end

      # Returns the columns included on the grid.
      def gpb_columns
        @columns
      end

      # Returns the dataset used on the grid.
      def gpb_data
        @collection
      end

      def html(options = {}, &block)
        options[:caption] = 'html' unless options[:caption]
        @columns << ProcColumn.new(block, options)
      end

      def field_with_helper(helper_method, field, options = {})
        @columns << HelperColumn.new(helper_method, field, {:caption => field.to_s.titleize}.merge(options))
      end

      def method_missing(field, options={})
        @columns << ListColumn.new(field, options)
      end

    end

    # list_builder_for is a helper to easily generate grids on index actions,
    # even though it can be used elsewhere.
    #
    # == Example
    #
    #   <%= list_builder_for @records do |list|
    #         list.name
    #         list.last_name
    #       end -%>
    #
    # At the administrate_me index action have the @records instance which holds
    # all the records that have to be displayed. On each instance we will call
    # the name and last_name methods over the <code>list</code> variable, this
    # will yield the inclusion of those two fields as columns on the generated
    # grid.
    #
    # As an implementation detail, the +list+ variable passed to a block, is an
    # instance of <code>GridPresentationBuilder</code> that is instantiated before
    # iterating over the records and holds the configuration for the grid.
    #
    # == Advanced options
    #
    # ==== Accessing data through associations
    #
    # You can also include columns with data that is not accessible with just one
    # method call on each records. Let's say you have a list of @records where each
    # item represents a product, those products are related to a brand using a
    # belongs_to association and you just want to include a column with the brand
    # name.
    # On cases like this you'll need to include +:with+ option on the method call
    # on the +list+ method. See an example:
    #
    #   <%= list_builder_for @records do |list|
    #         list.name
    #         list.brand :with => :name
    #       end -%>
    #
    # ==== Assigning column titles
    #
    # You'll have to use the +:caption+ option:
    #
    #   <%= list_builder_for @records do |list|
    #         list.name :caption => 'Product name'
    #         list.brand :with => :name, :caption => 'Brand name'
    #       end -%>
    #
    # By default, list_builder_for will use the titleized field names.
    #
    # ==== Assigning format to column
    #
    # The calls made to the +list+ variable to define columns on the grid also
    # accept options to change the format of the data displayed. This options set
    # the style attribute of the <td> element of each element on that column.
    #
    # Valid options:
    # * <tt>:width</tt> - Width of the column
    # * <tt>:color</tt> - Text color of the column.
    # * <tt>:string</tt> - Shows the results strongs (bold) if the value is true.
    # * <tt>:align</tt> - Sets the text-align attribute for the column.
    #
    #    <%= list_builder_for @records do |list|
    #         list.name        :width => '250px', :color => '#666666', :strong => true
    #         list.description
    #         list.price       :width => '100px', :align => :right
    #      end %>
    #
    # ==== Inserting free html
    #
    # You can also insert the html code you want in any cell of the table. To do
    # that you just need to call the <code>html</code> method on the list object
    # and pass it a block that can hadle a record of the table as a parameter.
    # Then the result of that block will be included as html on the table.
    #
    # Example: Let's say you have a model that uses the +paperclip+ plugin to
    # attach a file and you want to show a link to that file on the grid. You'll
    # have to do this:
    #
    #   <%= list_builder_for @records do |list|
    #         list.name :caption => 'User name'
    #         list.html :caption => 'Avantar' do |user_instance|
    #           image_tag(user_instance.avatar.url(:thumb))
    #         end
    #       end -%>
    #
    # ==== Calling a helper
    #
    # You can directly call a helper using a particular field of the record.
    #
    # In this example the currency_helper will be called receiving the amount value
    # for each instance. The helper's output will be used as output for that column
    # of the table.
    #
    #   <%= list_builder_for @records do |list|
    #         list.date
    #         list.field_with_helper(:currency_helper, :amount)
    #       end -%>
    #
    # ==== Report mode
    #
    # Using this mode the grid will be displayed without showing links to the actions
    # on each row.
    #
    #   <%= list_builder_for @libros_mas_vendidos, :report => true do |list|
    #         list.nombre
    #         list.total_ventas
    #       end %>
    #
    def list_builder_for(collection, options = {}, type = :grid)
      yield(list = GridPresentationBuilder.new(collection))
      list_renderer(list, options, type)
    end

    # Internally used by list_builder_for. Creates html output including a
    # flash message, the grid and the pagination when will_paginate is available.
    def list_renderer(list, options, type)
      html = []
      html << show_mini_flash rescue ""
      html << render_grid(list, options) if type == :grid
      html << render(:partial => 'commons/pagination', :locals => {:collection => list.gpb_data}) if list.gpb_data.respond_to?('total_pages') && !controller.show_all_records?
      html << pagination_links unless options[:report]
      html.compact.join("\n")
    end

    def pagination_links
      links = []
      links << link_to(t('views.see_all'), :all => '1') if !controller.show_all_records?
      links << link_to('Excel', :format => 'xls')       if controller.params[:format] != 'xls'
      !links.empty? ? content_tag(:div, links.join("\n"), :class => 'pagination') : nil
    end

    def render_grid(pb, options)
      unless pb.gpb_data.empty?
        html  = build_grid_header(pb)
        html << build_grid_body(pb, options)
        "<table class='admin_grid'>#{html}</table>"
      else
        render_empty_msg
      end
    end

    def build_grid_header(pb)
      html = ""
      pb.gpb_columns.each {|column| html << "<th> #{column.caption} </th>" }
      "<tr> #{ html } <th>&nbsp;</th> </tr>"
    end

    def build_grid_body(pb, options)
      html = ""
      pb.gpb_data.each{|item| html << build_row_for(pb, item, cycle('odd', 'even'), options) }
      html
    end

    def build_row_for(pb, item, css_class, options)
      html = ""
      pb.gpb_columns.each do |column|
        value = column.value_for(item, self)
        html << "<td style='#{column.style}'> #{value} </td>"
      end
      html << "<td class='link_options'> #{build_row_links(item)} </td>" unless options[:report] || @is_xml
      "<tr class='#{css_class}'> #{html} </tr>"
    end

    def build_row_links(item)
      html = ""
      #FIXME: should refactor to use link_to_destroy, link_to_edit, etc, merging with edit_action and destroy_action on presenter.rb
      html << link_to_show_action(t('views.view_action'), item)
      html << link_to_edit_action(t('views.edit_action'), item)
      html << link_to_destroy_action(t('views.destroy_action'), item)
      html
    end
  end
end

