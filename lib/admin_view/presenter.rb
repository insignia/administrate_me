module AdminView
  module Presenter
    class Presenter
      attr_reader :lines

      class HTMLBuilder
        def method_missing(tag, content)
          "<#{tag}>#{content}</#{tag}>"
        end
      end

      class Fielder
        def initialize(type)
          @type = type
          @mybuilder = HTMLBuilder.new
          @fields    = []
        end
        def field(label, value)
          data_block  = @mybuilder.span(label)
          data_block << @mybuilder.div(pretty_value(value))
          @fields << "<div class='data-block'>#{data_block}</div>"
        end
        def text(value)
          @fields << value
        end
        def render
          "<div class='#{@type.to_s}'> #{@fields.join} </div>"
        end
        def pretty_value(value)
          case value
            when TrueClass, FalseClass
              value ? I18n.translate(:yes) : I18n.translate(:no)
            when Date
              #FIXME: Revisit this, it needs to be localized.
              value.to_s.split('-').reverse.join('/')
            else
              value
          end
        end
      end

      def initialize
        @lines     = []
      end

      def method_missing(type, &block)
        block.call(r = Fielder.new(type))
        @lines << render_fielder(r)
      end

      def render_fielder(fielder)
        fielder.render
      end

      def present
        @lines.join
      end
    end

    def present(type, &block)
      block.call(p = Presenter.new)
      render_presentation(p, type.to_s)
    end

    def render_presentation(p, type)
      content_tag(:div, p.present, :class => type)
    end

    def edit_action
      link_to_edit_action(t('views.edit_this_record'), @resource)
    end

    def destroy_action
      link_to_destroy_action(t('views.delete_this_record'), @resource)
    end

    def back_action
      link_to t('views.back'), path_to_index, :class => 'neutro'
    end
  end
end

