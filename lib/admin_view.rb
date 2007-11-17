module AdminView
  def generate_navigation
    html = ""
    controller.modules.each do |tab|
      tab_name = get_tab_name
      selector = (tab_name == tab[:name].to_s) ? 'selected' : 'available'        
      html << content_tag('li', 
                          link_to(tab[:caption].humanize, tab[:url]), 
                          :class => selector )
    end    
    content_tag('ul', html, :id => 'navs')
  end
  
  def get_tab_name
    if controller.respond_to?('tab')
      tname = controller.tab.to_s
    else
      tname = controller.controller_name.to_s
    end
  end
  
  def show_section_header
    html  = show_section_label
    unless controller.options[:except] && controller.options[:except].include?(:new)
      html << content_tag('div', 
                          link_to( "agregar un nuevo #{controller.controller_name.singularize}", 
                                   eval("new_#{controller.controller_name.singularize}_path")),
                          :id => 'actions' )
    end
    html
  end
  
  def show_section_label
    show_label("Administración de #{controller.controller_name.humanize}")
  end
  
  def show_label(label)
    content_tag('div', label, :class => 'section_label')
  end
  
  def show_section_body
    content_tag('div', 
                render(:partial => 'list'), 
                :id => 'list_area')
  end
  
  def show_section_content
    html  = show_section_header
    html << show_section_body
    html
  end
    
  def show_mini_flash
    unless session[:mini].blank?      
      html  = content_tag('span', session[:mini])
      html << link_to('ver todos', path_to_index)
      content_tag('div', html, :id => 'mini_flash')
    end
  end
  
  def path_to_index
    path  = "#{controller.controller_name}_path"
    unless controller.options[:parent].blank?
      path << "(params[:#{controller.options[:parent].to_s}_id])"
    end
    eval(path)
  end
      
  def generate_grid_table_for(options = {})
    unless @records.blank?    
      html = generate_grid_table_heads(options[:fields])
      
      body = ""
      for item in @records      
        cells = generate_grid_table_cells(item, options[:fields], options[:actions])
        body << content_tag('tr', cells, :id => dom_id(item), :class => cycle('odd', 'even'))
      end
      
      html << body
      
      content_tag('table', html, :id => 'grid_table')
    else
      render_empty_msg
    end
  end 
  
  def generate_grid_table_heads(fields) 
    heads = ""
    fields.each do |field|
      heads << content_tag('th', field.humanize)
    end
    heads = content_tag('tr', heads)
    heads
  end
  
  def generate_grid_table_cells(item, fields, actions)
    cells = ""
    fields.each do |field|
      cells << content_tag('td', item.send(field))        
    end
    cells << generate_actions_links(item, actions)
    cells
  end
    
  
  def generate_actions_links(item, actions = [])
    name_space = controller.controller_name.singularize
    html = ""
    if actions
      if actions.include?('show')
        html << link_to(image_tag('show.png'), eval("#{name_space}_#{generate_path(item)}"), :title => 'ver más...')
      end
      if actions.include?('edit')
        html << link_to(image_tag('edit.png'), eval("edit_#{name_space}_#{generate_path(item)}"), :title => 'editar este registro')
      end
      if actions.include?('destroy')
        html << link_to(image_tag('destroy.png'), eval("#{name_space}_#{generate_path(item)}"), :confirm => 'El registro será eliminado definitivamente. ¿Desea continuar?', :method => :delete, :title => 'eliminar este registro')
      end
      unless html.blank?
        html = content_tag('div', html, :align => 'right')     
        html = content_tag('td', html)
      end
    end
    html
  end
  
  def generate_path(item)
    path = "path("
    unless controller.options[:parent].blank?
#      path << "item.send('#{controller.options[:parent]}_id'),"
      path << "@parent.id,"
    end
    path << "item)"
    path
  end
  
  def search_url
    str  = "{:action=>'search', "
    unless controller.options[:parent].blank?
      str << ":#{controller.options[:parent].to_s}_id => params[:#{controller.options[:parent].to_s}_id],"
    end
    str << ":only_path => false}"
    eval(str)
  end
  
  def edit_url
    str  = "#{controller.model_name}_path("
    unless controller.options[:parent].blank?
      str << "@resource.send('#{controller.options[:parent]}_id'),"
    end
    str << "@resource)"
    eval(str)
  end
  
  def search_scope
    "(#{controller.options[:search].map{|x| x.to_s.humanize}.join(', ')})"
  end
  
  def render_flash_message
    html = ""
    if flash[:notice] || flash[:error]    
      html = content_tag('div', flash[:notice], :class => 'success') unless flash[:notice].blank?
      html = content_tag('div', flash[:error],  :class => 'error')   unless flash[:error].blank?
      html = content_tag('div', html, :id => 'flash')
    end
    html
  end
  
  def html
    aux = {}
    if controller.respond_to?('form_settings')
      aux = controller.form_settings
    end
    aux[:method] = :put if controller.action_name == 'edit'
    aux
  end
end

ActionView::Base.send :include, AdminView