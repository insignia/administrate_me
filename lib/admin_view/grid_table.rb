module AdminView
  module GridTable
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
  end
end

