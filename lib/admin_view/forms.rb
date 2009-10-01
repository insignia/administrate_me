module AdminView
  module Forms
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
      @resource.new_record? ? path_to_index : path_to_element(@resource)
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
  end
end

