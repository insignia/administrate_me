module AdminView::PresentationBuilder
  class PresentationBuilder
    class ListColumn      
      def initialize(field, options={})
        @field = field
        @options = options
      end
      
      def value_for(item)
        item.send(@field)
      end
      
      def caption
        @options[:caption] ? @options[:caption] : @field
      end
      
      def style
        @options[:style]
      end
    end
    
    def initialize(collection)
      @collection = collection
      @columns = []
      @rows    = []
      @captions = {}
    end        
    
    def columns
      @columns
    end
    
    def data
      @collection
    end
   
    
    def method_missing(field, options={})
      @columns << ListColumn.new(field, options)      
    end
    
    
  end    
  
  def build_grid_header(pb)
    html = ""
    pb.columns.each{|column| html << "<th> #{column.caption.to_s.titleize} </th>" }
    "<tr> #{ html } </tr>"
  end
  
  def build_grid_body(pb)
    html = ""
    pb.data.each{|item| html << build_row_for(pb, item, cycle('odd', 'even')) }
    html
  end
  
  def build_row_for(pb, item, css_class)
    html = ""
    pb.columns.each do |column| 
      html << "<td style='#{column.style}'> #{column.value_for(item)} </td>"      
    end         
    html << "<td class='link_options'> #{build_row_links(item)} </td>"
    "<tr class='#{css_class}'> #{html} </tr>"
  end
  
  def build_row_links(item)
    html = ""    
    html << link_to(image_tag('admin_ui/show.png'), path_to_element(item), :title => 'ver más...') if controller.class.accepted_action(:show)
    html << link_to(image_tag('admin_ui/edit.png'), path_to_element(item, :edit), :title => 'editar este registro') if controller.class.accepted_action(:edit)
    html << link_to(image_tag('admin_ui/destroy.png'), path_to_element(item), :confirm => 'El registro será eliminado definitivamente. ¿Desea continuar?', :method => :delete, :title => 'eliminar este registro') if controller.class.accepted_action(:destroy)
    html 
  end
  
  def render_grid(pb)
    unless pb.data.empty?
      html  = build_grid_header(pb)
      html << build_grid_body(pb)
      "<table class='admin_grid'>#{html}</table>"
    else
      render_empty_msg
    end
  end
  
  
  def list_builder_for(collection, type = :grid)
    yield(list = PresentationBuilder.new(collection))
    list_renderer(list, type)    
  end
  
  def list_renderer(list, type)
    html  = ""
    html << show_mini_flash rescue ""
    html << render_grid(list) if type == :grid
    html << render(:partial => 'commons/pagination') if controller.model_class.respond_to?('paginate')
    html
  end
end

ActionView::Base.send :include, AdminView::PresentationBuilder