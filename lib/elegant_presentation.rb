module AdminView::ElegantPresentation
  def render_resource_context(options={})
    html = ""
    unless controller.respond_to?(:render_context_condition) && controller.render_context_condition == false
      unless controller.options[:parent].blank?
        html << content_tag('span', controller.options[:parent].to_s.humanize, :class => 'context')
        html << content_tag('h3', @parent.send(controller.context[:highlight]))
        html << content_tag('span', @parent.send(controller.context[:description]), :class => 'body' )
        unless options[:no_back]
          html << content_tag('div', link_to('volver', eval("#{controller.options[:parent]}_path(@parent)")), :class => 'actions') 
        end
        html  = content_tag('div', html, :class => 'resource_context')
      else
        html = ""
      end
    end
    html
  end
  
  def render_context_with(attr)
    html  = "#{@parent.class} > "
    html << link_to(@parent.send(attr), controller.send("#{@parent.class.to_s.downcase}_path", @parent))
    content_tag(:div, html, :id => :context)
  end
  
  def related_info_for(group, links=[])
    html = content_tag('h3', group)
    lis  = ""
    links.each do |link|
      lis << content_tag('li', link_to(link[:link], link[:url], :method => link[:method] || nil))
    end
    html << content_tag('ul', lis)
    content_tag('div', html, :class => 'related_info')
  end   
  
  def simple_list(highlight, description)
    html = ""
    unless @records.blank?
      for item in @records
        str  = content_tag('h3', item.send(highlight))
        str << content_tag('span', item.send(description)) unless description.blank?
        str  = content_tag('div', str)
        str  = link_to(str, path_to_element(item))
        html << content_tag('li', str, :class => cycle('odd', 'even'))
      end
      content_tag('ul', html, :class => 'list')
    else
      render_empty_msg
    end
  end
  
  def render_empty_msg
    content_tag('div', 'No hay registros cargados', :class => 'msg')
  end
  
  def render_action_label
    case controller.action_name
      when "new"
        label = "Nuevo registro de #{controller.controller_name.humanize}"
      when "edit"
        label = "Editando un registro de #{controller.controller_name.humanize}"      
    end
    content_tag('div', label, :class => 'section_label')
  end
  
end

ActionView::Base.send :include, AdminView::ElegantPresentation