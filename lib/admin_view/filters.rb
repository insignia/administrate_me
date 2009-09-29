module AdminView
  module Filters
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
  end
end

