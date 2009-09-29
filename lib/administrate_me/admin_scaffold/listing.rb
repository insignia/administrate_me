module AdministrateMe
  module AdminScaffold
    module Listing
      protected
        def get_list
          session[:mini] = ''
          params[:search_key] ||= session["#{controller_name}_search_key"] if session["#{controller_name}_search_key"]
          @search_key = params[:search_key]
          get_records
          set_search_message
          session["#{controller_name}_search_key"] = @search_key
        end

        def get_records
          conditions = model_class.merge_conditions_backport(*[parent_scope, global_scope, search_scope])
          options = {:conditions => conditions, :include => get_includes, :order => get_order}
          if model_class.respond_to?('paginate') && !show_all_records?
            @records = apply_scopes.paginate(options.merge(:page => params[:page], :per_page => get_per_page))
            @count_for_search = @records.total_entries
          else
            @records = apply_scopes.find(:all, options)
            @count_for_search = @records.size
          end
        end

        def apply_scopes
          final_scope = model_class.scoped({})
          filter_scopes.each do |scope|
            final_scope = final_scope.scoped(scope)
          end
          final_scope
        end

        def filter_scopes
          scopes = []
          if filter_config
            scopes << filter_config.options_for_filter(self, active_filter)
            session[:combo_filters][self.class.to_s].each do |filter_name, value|
              if value
                scopes << filter_config.options_for_filter(self, filter_name, value)
              end
            end
          end
          scopes.compact
        end

        def get_per_page
          options[:per_page] || model_class.per_page || 15
        end

        def get_includes
          options[:includes] || nil
        end

        def get_order
          options[:order_by] || nil
        end

        def get_list_options
          list_options = {}
          list_options[:per_page] = (options[:per_page]) ? options[:per_page] : 15
          list_options[:order]    = options[:order_by] rescue nil
          list_options
        end

        def set_search_message
          if options[:search] && !params[:search_key].blank?
            session[:mini] = I18n.t('messages.search_message', :count => @count_for_search, :search_key => @search_key)
          end
        end

        def parent_scope
          parent = options[:parent]
          foreign_key = options[:foreign_key].blank? ? "#{options[:parent]}_id" : options[:foreign_key]
          if parent
            { foreign_key => @parent.id }
          end
        end

        def global_scope
          respond_to?('general_conditions') ? general_conditions : nil
        end

        def search_scope
          !@search_key.blank? && options[:search] ? conditions_for(options[:search]) : nil
        end

        def filter_scope
          if filter_config
            conditions = []
            conditions << filter_config.conditions_for_filter(self, active_filter)
            session[:combo_filters][self.class.to_s].each do |filter_name, value|
              if value
                filter = filter_config.filter_by_name(self, filter_name)
                conditions << filter.conditions(value)
              end
            end
            model_class.merge_conditions_backport(*conditions)
          end
        end

        # By default the search conditions will be created OR'ing all fields
        # on the administrate_me configuration using the LIKE sql clause.
        #
        # == Example
        #
        #   class PeopleController < ApplicationController
        #     administrate_me do |a|
        #       a.search :first_name, :last_name
        #     end
        #   end
        #
        # The condition will be along the lines of:
        #
        #   lower(first_name) LIKE '%john%' OR lower(last_name) LIKE '%john%'
        #
        def conditions_for(fields=[])
          predicate = []
          values    = []
          fields.each do |field|
            predicate << "lower(#{field.to_s}) like ?"
            values    << "'%' + @search_key.downcase + '%'"
          end
          eval("[\"#{predicate.join(' OR ')}\", #{values.join(',')}]")
        end
    end
  end
end

