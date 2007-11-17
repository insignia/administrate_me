module AdminView::ElegantPresentation

  def elegant_presentation_for(options={})
    html = ""
    if options[:on_header]
      html << render_elegant_header(options[:on_header])
    end
    if options[:on_body]
      html << render_elegant_body(options[:on_body])
    end
    html << render_elegant_actions(options[:no_actions])
    content_tag('div', html, :class => 'elegant_presentation')
  end

  def render_elegant_header(fields)
    html = ""
    fields.each do |field|
      html << content_tag('span', field.to_s.humanize, :class => 'label')
      html << content_tag('h3',   @resource.send(field.to_s))      
    end
    content_tag('div', html, :class => 'header')
  end
  
  def render_elegant_body(fields)
    html = ""
    fields.each do |field|
      body  = content_tag('span', field.to_s.humanize, :class => 'label') << "<br />"
      body << content_tag('div', @resource.send(field.to_s), :class => 'content')
      html << content_tag('div', body)
    end
    content_tag('div', html, :class => 'body')
  end
  
  def render_elegant_actions(show)
    html  = ""
    unless show
      html << render_edit_action
      html << render_destroy_action
    end
    html << render_back_action
    content_tag('div', html, :class => 'actions')
  end

  def render_edit_action
    link_to('Editar este registro', eval(generate_edit_path))
  end
  
  def render_destroy_action
    link_to('Eliminar este registro', eval(generate_target_path), :confirm => 'Are you sure?', :method => :delete, :class => 'delete')
  end  
  
  def generate_edit_path
    str  = "edit_"
    str << generate_target_path
    str
  end
  
  def generate_target_path
    str = "#{controller.model_name}_path("
    unless controller.options[:parent].blank?
      str << "@resource.send('#{controller.options[:parent]}_id'), "
    end
    str << "@resource)"
    str
  end
  
  def render_back_action
    str = "#{controller.controller_name}_path"
    unless controller.options[:parent].blank?
      str << "(@resource.send('#{controller.options[:parent]}_id'))"
    end    
    link_to 'Volver', eval(str), :class => 'neutro'
  end
  
  def render_resource_context(options={})
    html = ""
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
    html
  end
  
  def related_info_for(group, links=[])
    html = content_tag('h3', group)
    lis  = ""
    links.each do |link|
      lis << content_tag('li', link_to(link[:link], link[:url]))
    end
    html << content_tag('ul', lis)
    content_tag('div', html, :class => 'related_info')
  end   
  
  def simple_list(highlight, description)
    html = ""
    for item in @records
      str  = content_tag('h3', item.send(highlight))
      str << content_tag('span', item.send(description))
      str  = content_tag('div', str)
      str  = link_to(str, eval("#{controller.model_name}_#{generate_path(item)}"))
      html << content_tag('li', str, :class => cycle('odd', 'even'))
    end
    content_tag('ul', html, :class => 'list')
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