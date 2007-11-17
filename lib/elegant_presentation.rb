module AdminView::ElegantPresentation

  def elegant_presentation_for(options={})
    html = ""
    if options[:on_header]
      html << render_elegant_header(options[:on_header])
    end
    if options[:on_body]
      html << render_elegant_body(options[:on_body])
    end
    unless options[:no_actions]
      html << render_elegant_actions
    end
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
      body << content_tag('span', @resource.send(field.to_s), :class => 'content')
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
    link_to('Editar este registro', generate_edit_path)
  end
  
  def generate_edit_path
    str  = "edit_#{controller.model_name}_path("
    unless controller.options[:parent].blank?
      str << "@resource.send('#{controller.options[:parent]}_id'), "
    end
    str << "@resource)"
    eval(str)
  end
  
  def render_back_action
    link_to 'Volver', "javascript:history.back()", :class => 'neutro'
  end
  
end

ActionView::Base.send :include, AdminView::ElegantPresentation