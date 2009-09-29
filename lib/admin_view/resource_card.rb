module AdminView
  module ResourceCard
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
  end
end

