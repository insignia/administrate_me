module AdminView
  module Backend
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
      if type == :css
        controller.respond_to?('admin_style')   ? controller.admin_style   : controller.default_style
      else
        controller.respond_to?('admin_scripts') ? controller.admin_scripts : controller.default_js
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

    def current_class(is_current)
      is_current ? 'current' : nil
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
end

