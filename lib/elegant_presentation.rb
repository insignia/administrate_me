module AdminView::ElegantPresentation

  def render_elegant_presentation_for(object, options={})
    html = ""
    if options[:on_header]
      html << render_elegant_header(object, options[:on_header])
    end
    if options[:on_body]
      html << render_elegant_body(object, options[:on_body])
    end
    unless options[:no_actions]
      html << render_elegant_actions
    end
    content_tag('div', html, :class => 'elegant_presentation')
  end

  def render_elegant_header(object, fields)
    html = ""
    fields.each do |field|
      html << content_tag('span', field.to_s.humanize, :class => 'label')
      html << content_tag('h3',   object.send(field.to_s))      
    end
    content_tag('div', html, :class => 'header')
  end
  
  def render_elegant_body(object, fields)
    html = ""
    fields.each do |field|
      body  = content_tag('span', field.to_s.humanize, :class => 'label') << "<br />"
      body << content_tag('span', object.send(field.to_s), :class => 'content')
      html << content_tag('div', body)
    end
    content_tag('div', html, :class => 'body')
  end
  
  def render_elegant_actions
    html  = render_edit_action
    html << render_back_action
    content_tag('div', html, :class => 'actions')
  end

  def render_edit_action
    control = controller.model_name
    link_to 'Editar este registro', eval("edit_#{control}_path(@resource)")
  end
  
  def render_back_action
    link_to 'Volver', "javascript:history.back()", :class => 'neutro'
  end
  
end

ActionView::Base.send :include, AdminView::ElegantPresentation