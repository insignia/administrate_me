module AdminView::PresentationBuilder
  class PresentationBuilder
    class ListColumn      
      def initialize(field, options={})
        @field = field
        @options = options
      end
      
      def value_for(item)
        @options[:with] ? related_value_for(item.send(@field)) : item.send(@field)
      end
      
      def related_value_for(value)
        if value.is_a?(Array)
          rtn = value.map{|x| x.send(@options[:with])}.join(", ")
        else
          rtn = value.send(@options[:with])
        end
        rtn
      end
      
      def caption
        @options[:caption] ? @options[:caption] : @field
      end
      
      def style
        @options[:style] = ""
        @options[:style] << custom_grid unless custom_grid.empty?
      end
      
      def custom_grid
        customizations = []
        customizations << "width:#{@options[:width]}"      if @options[:width]
        customizations << "color:#{@options[:color]}"      if @options[:color]
        customizations << "font-weight:bold"               if @options[:strong]
        customizations << "text-align:#{@options[:align]}" if @options[:align]
        customizations.join(';')
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
  
  def build_grid_body(pb, options)
    html = ""
    pb.data.each{|item| html << build_row_for(pb, item, cycle('odd', 'even'), options) }
    html
  end
  
  def build_row_for(pb, item, css_class, options)
    html = ""
    pb.columns.each do |column| 
      html << "<td style='#{column.style}'> #{column.value_for(item)} </td>"      
    end             
    html << "<td class='link_options'> #{build_row_links(item)} </td>" unless options[:report]
    "<tr class='#{css_class}'> #{html} </tr>"
  end
  
  def build_row_links(item)
    html = ""    
    html << link_to(image_tag('admin_ui/show.png'), path_to_element(item), :title => 'ver más...') if controller.class.accepted_action?(:show)
    html << link_to(image_tag('admin_ui/edit.png'), path_to_element(item, :prefix => :edit), :title => 'editar este registro') if controller.class.accepted_action?(:edit)
    html << link_to(image_tag('admin_ui/destroy.png'), path_to_element(item), :confirm => 'El registro será eliminado definitivamente. ¿Desea continuar?', :method => :delete, :title => 'eliminar este registro') if controller.class.accepted_action?(:destroy)
    html 
  end
  
  def render_grid(pb, options)
    unless pb.data.empty?
      html  = build_grid_header(pb)
      html << build_grid_body(pb, options)
      "<table class='admin_grid'>#{html}</table>"
    else
      render_empty_msg
    end
  end
  
  
  def list_builder_for(collection, options = {}, type = :grid)
    yield(list = PresentationBuilder.new(collection))
    list_renderer(list, options, type)    
  end
  
  def list_renderer(list, options,type)
    html  = ""
    html << show_mini_flash rescue ""
    html << render_grid(list, options) if type == :grid
    html << render(:partial => 'commons/pagination') if controller.model_class.respond_to?('paginate')
    html
  end
end

ActionView::Base.send :include, AdminView::PresentationBuilder
