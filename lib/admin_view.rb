module AdminView

  # resource_card helper
  # this helper render a very elegant presentation card for a resource.
  #   
  #   <% resource_card do %>
  #     <%= row_for  "Name",        @resource.name %>
  #     <%= row_for  "Name",        @resource.name %>
  #     <%= area_for "Description", @resource.description %>
  #     <%= row_for  "Name",        @resource.name %>
  #     <%= row_for  "Date",        Date.today.to_s %>
  #     <%= render_buttons %>
  #   <% end %>
  #
  def resource_card(&block)
    content = capture(&block)
    concat(show_section_label,                block.binding)
    concat('<div class="resource-card">',     block.binding)
    concat(content,                           block.binding)
    concat('</div>',                          block.binding)
    concat('<div style="clear:both;"></div>', block.binding)
  end
  
  def row_for(label, value)
    html  = '<div class="rc-block">'
    html << '  <div class="rc-row rc-caption">'+label+'</div>'
    html << '  <div class="rc-row rc-content">'+"#{value.blank? ? '-' : value}"+'</div>'
    html << '</div>'
    html
  end
  
  def area_for(label, value)
    html  = '<div class="rc-block">'
    html << '  <div class="rc-area rc-label">'+label+'</div>'
    html << '  <div class="rc-area rc-detail">'+"#{value.blank? ? '-' : value}"+'</div>'
    html << '</div>'
    html
  end
  
  def render_buttons
    html  = '<div class="buttons">'
    html << edit_action    if controller.class.accepted_action?(:edit)
    html << destroy_action if controller.class.accepted_action?(:destroy)
    html << back_action
    html << '</div>'
    html
  end  

  # field_block helper
  # 
  # Use this helper to set a two column fieldset layout for an admin form.
  # 
  # usage: in a _form.html.erb
  # 
  #   <% field_block do %>
  #     <%= t.text_field :name %>
  #     <%= t.text_field :code %>
  #   <% end %>
  # 
  # note: this two input boxes will be rendered in a single row
  #
  def field_block(&block)
    content = capture(&block)
    concat('<div class="float_left">',        block.binding)
    concat(content,                           block.binding)
    concat('</div>',                          block.binding)
    concat('<div style="clear:both;"></div>', block.binding)
  end

  def generate_navigation
    html = ""
    if modules = get_modules
      modules.each do |tab|
        tab_name = get_tab_name
        selector = (tab_name == tab[:name].to_s) ? 'current' : 'available'        
        html << content_tag('li', 
                            link_to(content_tag('span', tab[:caption].humanize), tab[:url], :class => selector), 
                            :id => tab[:name] )
      end    
      content_tag('ul', html, :id => 'navs')
    else
      raise Exception, "Debe definir los módulos para la aplicación. Ver: http://code.google.com/p/administrateme/wiki/ConfiguracionDeModulos"
    end
  end
  
  def admin_file_loader
    html = ""
    html << file_loader_for(:css)
    html << file_loader_for(:javascript)
    html
  end
  
  def file_loader_for(type)
    html = ""    
    files_to_load(type).each do |file|
      html << file_inclusion(type, file)
    end    
    html
  end
  
  def files_to_load(type)
    if type == :css
      controller.respond_to?('admin_style') ? controller.admin_style : ["admin_look", "reset-fonts-grids"] 
    else    
      controller.respond_to?('admin_scripts') ? controller.admin_scripts : [:defaults, "admin_ui.js"]
    end
  end
  
  def file_inclusion(type, file)
    args = [*file]
    (type == :css) ? stylesheet_link_tag(*args) : javascript_include_tag(*args)
  end
  
  def get_modules
    if controller.respond_to?('modules')
      controller.instance_variable_set("@instance_modules", [])
      controller.modules
      controller.instance_variable_get("@instance_modules")
    else
      controller.class.ame_modules
    end
  end

  def get_tab_name
    if controller.respond_to?('tab')
      tname = controller.tab.to_s
    else
      tname = controller.controller_name.to_s
    end
  end
  
  def show_section_header
    show_section_label
  end
  
  def show_section_links
    links  = link_to( "Agregar nuevo registro", 
                      path_to_index(:new))
    if controller.options[:excel]
      links << link_to( "Descargar a Excel", eval("excel_#{controller.controller_name}_path"))
    end
    links
  end
  
  def show_section_label
    show_label("#{controller.controller_name.humanize}")
  end
  
  def show_label(label)
    content_tag('h1', label, :id => 'section_label')
  end
  
  def show_section_body
    content_tag('div', 
                render(:partial => 'list'), 
                :id => 'list_area')
  end
  
  def show_search_form
    content_tag('div', render(:partial => 'commons/search_form'), :id => 'search')
  end

  # This helper is used to show the main index sections. 
  # Returns the header, search form and renders de list of elements.
  def show_section_content
    html  = show_section_header
    if controller.options[:search]
      html << show_search_form
    end
    html << show_section_body
    html
  end
    
  def show_mini_flash
    unless session[:mini].blank?      
      html  = content_tag('span', session[:mini])
      content_tag('div', html, :id => 'mini_flash')
    end
  end
  
  def path_to_index(*args)
    controller.path_to_index(*args)
  end
  
  def path_to_element(*args)
    controller.path_to_element(*args)
  end
      
  def generate_grid_table_for(options = {})
    unless @records.blank?    
      html = generate_grid_table_heads(options[:fields])
      
      body = ""
      for item in @records      
        cells = generate_grid_table_cells(item, options[:fields], options[:actions])
        body << content_tag('tr', cells, :id => "item_#{item.id}", :class => cycle('odd', 'even'))
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
#        html << link_to(image_tag('admin_ui/show.png'), eval("#{name_space}_#{generate_path(item)}"), :title => 'ver más...')
      end
      if actions.include?('edit')
        html << link_to(image_tag('edit.png'), eval("edit_#{name_space}_#{generate_path(item)}"), :title => 'editar este registro')
#        html << link_to(image_tag('admin_ui/edit.png'), eval("edit_#{name_space}_#{generate_path(item)}"), :title => 'editar este registro')
      end
      if actions.include?('destroy')
        html << link_to(image_tag('destroy.png'), eval("#{name_space}_#{generate_path(item)}"), :confirm => 'El registro será eliminado definitivamente. ¿Desea continuar?', :method => :delete, :title => 'eliminar este registro')
#        html << link_to(image_tag('admin_ui/destroy.png'), eval("#{name_space}_#{generate_path(item)}"), :confirm => 'El registro será eliminado definitivamente. ¿Desea continuar?', :method => :delete, :title => 'eliminar este registro')
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
      path << "@parent.id,"
    end
    path << "item)"
    path
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
    aux[:method] = :put if ['edit', 'update'].include?(controller.action_name)
    aux[:id] = controller.model_name
    aux
  end

  def form_name_space
    rtn  = [] 
    rtn << controller.class.namespace.to_sym unless controller.class.namespace.blank?
    rtn << @parent                           if     @parent
    rtn << @resource                         if     @resource
    rtn
  end

  # Deprecated: filters_for() helper should be used instead
  def show_filters_for(filters = [])
    html = ""
    lis  = ""
    unless filters.blank?
      html << content_tag(:div, 'Filtrar registros por...', :class => 'f_header')     
      filters.each do |filter|
        link = link_to(filter[:caption], filter[:url])
        lis << content_tag(:li, link, :class => current_class(filter[:name_space].to_s == controller.active_filter))
      end
      html << content_tag(:ul, lis, :class => 'filters')
    end
    html
  end
  deprecate :show_filters_for

  def filters_for(&block)
    concat("<div class=\"f_header\">Filtrar registros por...</div>",  block.binding)
    concat("<ul class=\"filters\">", block.binding)
    yield
    concat("</ul>",                  block.binding)
    concat("</div>",                 block.binding)
  end

  def all_filters
    results = []
    results << filter_by('Todos', :none)
    controller.options[:filter_config].all_filters.each do |filter|
      results << filter_by(filter.label, filter.name)
    end
    results.join("\n")
  end

  def filter_by(label, filter_name = nil)
    if controller.options[:filter_config].is_combo?(filter_name)
      filter_by_combo(label, filter_name)
    else
      filter_by_link(label, filter_name)
    end
  end

  def filter_by_link(label, filter_name)
    link = link_to(label, path_to_index(:filter => filter_name))
    content_tag(:li, link, :class => current_class(filter_name.to_s == 'none' && !controller.active_filter || filter_name == controller.active_filter))
  end

  def filter_by_combo(label, filter_name)
    filter = controller.options[:filter_config].filter_by_name(filter_name)
    combo_name = "combo_filter_#{filter.name}"
    content = content_tag(:label, label) + combo_select_tag(filter, combo_name)
    content_tag(:li, content, :class => 'combo_filter') +
      observe_field(combo_name, :url => path_to_index(:combo_filter => filter.name), :with => 'combo_value', :method => :get)
  end

  def combo_select_tag(filter, combo_name)
    select_tag(combo_name,
      options_for_select(filter.options_for_select, session[:combo_filters][controller.class][filter.name]), :id => combo_name)
  end

  def list_for(group, settings = {})
    header  = (settings[:label]) ? settings[:label] : group.to_s.humanize
    html    = content_tag(:div, header, :class => 'header')    
    settings[:collection].each do |item|
      aux   = (settings[:not_show]) ? '#' : link_to_show(group, item, settings)
      link  = link_to(item.send(settings[:field]), aux)
      html << content_tag(:li, link, :class => cycle('odd', 'even') )
    end
    html  = content_tag(:ul, html, :id => 'list')
    html << link_to_more(settings[:link]) if settings[:link]
    html
  end
  
  def link_to_show(group, item, options)
    controller_name = options[:controller_name] || group.to_s.singularize
    namespace = options[:namespace] || controller.class.namespace
    new_options = options.dup
    new_options[:parent] = new_options.delete(:parent_name)
    controller.send(:create_path, controller_name, item, namespace, options[:parent], new_options)
  end
  
  def link_to_more(ltmore)
    html = link_to('administrar', ltmore)
    content_tag(:div, html, :class => 'more')
  end
  
  def current_class(is_current)
    is_current ? 'current' : nil
  end
  
end

ActionView::Base.send :include, AdminView
