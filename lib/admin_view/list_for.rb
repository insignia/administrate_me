module AdminView
  module ListFor
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
  end
end

