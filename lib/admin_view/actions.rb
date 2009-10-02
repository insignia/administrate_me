module AdminView
  module Actions
    def smart_path(member = nil)
      controller.smart_path(member)
    end

    def path_to_index(options = {})
      options[:action] ||= 'index'
      smart_path.merge(options)
    end

    def path_to_element(element, options = {})
      options[:action] ||= 'show'
      smart_path(element).merge(options)
    end

    def link_to_new_action
      if controller.accepted_action?(:new)
        link_to( "#{t('views.add_new_record')} #{controller.model_name.titleize}",
                 path_to_index(:action => :new), :class => :add_new )
      end
    end

    def link_to_edit_action(title, resource)
      rtn = ""
      if controller.accepted_action?(:edit)
        rtn = link_to(title, path_to_element(resource, :action => :edit), :title => t('views.edit_this_record'))
      end
      rtn
    end

    def link_to_destroy_action(title, resource)
      rtn = ""
      if controller.accepted_action?(:destroy)
        rtn = link_to(title, path_to_element(resource),
                      :confirm => t('views.delete_confirm'), :method => :delete,
                      :title => t('views.delete_this_record'), :class => :destroy)
      end
      rtn
    end

    def link_to_show_action(title, resource)
      rtn = ""
      if controller.accepted_action?(:show)
        rtn = link_to(title, path_to_element(resource), :title => t('views.see_more'))
      end
      rtn
    end

    def link_to_parent
      context = controller.options[:context]
      caption = context ? @parent.send(context) : @parent.class
      link_to(caption.titleize, controller.path_to_parent(@parent))
    end
  end
end

