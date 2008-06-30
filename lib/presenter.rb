module AdminView::Presenter
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
        @fields << @mybuilder.span(label)
        @fields << @mybuilder.div(pretty_value(value))
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
            value ? 'Sí' : 'No'
          when Date
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
    link_to('Editar este registro', path_to_element(@resource, :prefix => :edit))
  end
  
  def destroy_action
    link_to('Eliminar este registro', path_to_element(@resource), :confirm => 'Eliminará definitivamente este registro. ¿Está seguro?', :method => :delete, :class => 'delete')
  end
  
  def back_action
    link_to 'Volver', path_to_index, :class => 'neutro'
  end
end

ActionView::Base.send :include, AdminView::Presenter