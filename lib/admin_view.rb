module AdminView

  def link_to_parent
    context = controller.options[:context]
    caption = context ? @parent.send(context) : @parent.class
    link_to(caption, controller.path_to_parent(@parent))
  end

  def admin_context
    parts  = []
    parts << ">"
    if @parent
      parts << link_to_parent
      parts << ">"
    end
    parts << controller.controller_name.titleize
    parts.join(" ")
  end

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
    concat(show_section_label,                block.binding)
    concat('<div class="resource-card">',     block.binding)
    yield
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
    html << edit_action    if controller.accepted_action?(:edit)
    html << destroy_action if controller.accepted_action?(:destroy)
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
  def field_block(cols = 2, &block)
    css_class  = "float_left"
    css_class << "_#{cols}" unless cols == 2
    concat('<div class="'+ css_class +'">',        block.binding)
    yield
    concat('</div>',                          block.binding)
    concat('<div style="clear:both;"></div>', block.binding)
  end

  def generate_navigation
    tabs = []
    if modules = get_modules
      modules.each do |tab|
        selector = (get_tab_name == tab[:name].to_s) ? 'current' : 'available'
        tabs << OpenStruct.new(:caption => tab[:caption].humanize, :url => tab[:url], :class_name => selector, :name => tab[:name])
      end
      tabs
    else
      raise Exception, t('errors.modules_not_defined')
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
    default_style = ['css-reset', 'admin_look', 'ame-backport', 'admin_custom', ['admin_look_print', {:media => 'print'}]]
    default_js    = [:defaults,   'admin_ui.js']
    if type == :css
      controller.respond_to?('admin_style')   ? controller.admin_style   : default_style
    else
      controller.respond_to?('admin_scripts') ? controller.admin_scripts : default_js
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
      controller.tab.to_s
    elsif controller.options[:tab]
      controller.options[:tab].to_s
    elsif controller.options[:parent]
      controller.options[:parent].to_s.pluralize
    else
      controller.controller_name.to_s
    end
  end

  def show_section_header
    show_section_label
  end

  def show_section_links
    links  = link_to(t('views.add_new_record'),
                      path_to_index(:new))
    if controller.options[:excel]
      links << link_to(t('views.download_to_excel'), eval("excel_#{controller.controller_name}_path"))
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
    show_search_form
    content_tag('div',
                render(:partial => 'list'),
                :id => 'list_area')
  end

  def show_search_form
    content_for(:search) do
      content_tag('div', render(:partial => 'commons/search_form'), :id => 'search')
    end
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
        html << link_to(image_tag('show.png'), eval("#{name_space}_#{generate_path(item)}"), :title => t('views.see_more'))
      end
      if actions.include?('edit')
        html << link_to(image_tag('edit.png'), eval("edit_#{name_space}_#{generate_path(item)}"), :title => t('views.edit_this_record'))
      end
      if actions.include?('destroy')
        html << link_to(image_tag('destroy.png'), eval("#{name_space}_#{generate_path(item)}"), :confirm => t('views.delete_confirm'), :method => :delete, :title => t('views.delete_this_record'))
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

  def filters_for(&block)
    unless controller.filter_config.nil?
      concat("<div id='filter-list'>")
      concat("<div class='f_header'>#{t('views.filter_by')}</div>")
      concat("<ul class='filters'>")
      yield
      concat("</ul>")
      concat("</div>")
    end
  end

  def all_filters
    unless controller.filter_config.nil?
      results = []
      results << filter_by(t('views.filter_show_all'), :none)
      controller.filter_config.all_filters(controller).each do |filter|
        results << filter_by(filter.label, filter.name)
      end
      results.join("\n")
    end
  end

  def filter_by(label, filter_name = nil)
    if controller.filter_config.is_combo?(controller, filter_name)
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
    filter = controller.filter_config.filter_by_name(controller, filter_name)
    combo_name = "combo_filter_#{filter.name}"
    if combo = combo_select_tag(filter, combo_name)
      content = content_tag(:label, label) + combo
      content_tag(:li, content, :class => 'combo_filter') +
        observe_field(combo_name, :url => path_to_index(:combo_filter => filter.name), :with => 'combo_value', :method => :get)
    end
  end

  def combo_select_tag(filter, combo_name)
    if options_for_select = filter.options_for_select(controller)
      select_tag(combo_name,
        options_for_select(options_for_select, session[:combo_filters][controller.class.to_s][filter.name]), :id => combo_name)
    end
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
    html = link_to(t('views.admin'), ltmore)
    content_tag(:div, html, :class => 'more')
  end

  def current_class(is_current)
    is_current ? 'current' : nil
  end

  # Add a spinner, hidden by default, with the specified id.
  def spinner(spinner_id = :spinner, hidden = true)
    options = {:id => spinner_id}
    options.merge!(:style => 'display:none') if hidden
    image_tag('admin_ui/indicator.gif', options)
  end

  # Provide options for ajax helpers with default loading and complete options.
  #
  # ==== Example
  #
  #   observe_field(:some_field_id, loading_with_spinner(:spinner_id, :url => update_path, :with => 'value')
  #
  # the <code>loading_with_spinner</code> helper will add loading and complete
  # actions to the observe_field options to show and hide the spinner while the
  # action is being executed,
  def loading_with_spinner(spinner_id, options)
    options.merge(
      :loading  => "$('#{spinner_id}').show(); #{options[:loading]}",
      :complete => "$('#{spinner_id}').hide(); #{options[:complete]}"
    )
  end

  def link_to_new_action
    if controller.accepted_action?(:new)
      link_to( "#{t('views.add_new_record')} #{controller.model_name.titleize}",
               path_to_index(:new), :class => :add_new )
    end
  end

  def title
    controller.respond_to?('title') ? controller.title : t('views.default_title')
  end

  def owner
    controller.respond_to?('owner') ? controller.owner : 'nobody'
  end

  def app_name
    controller.respond_to?('app_name') ? controller.app_name : 'administrate_me'
  end

  #
  # This helper method is inspired by Fudgestudio's bort rails app.
  # http://github.com/fudgestudios/bort/tree/master
  #
  def flash_messages
    messages = []
    %w(notice warning error).each do |msg|
      messages << content_tag(:div, html_escape(flash[msg.to_sym]), :id => "flash-#{msg}") unless flash[msg.to_sym].blank?
    end
    messages
  end

end

ActionView::Base.send :include, AdminView

