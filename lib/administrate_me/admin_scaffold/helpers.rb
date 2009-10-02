module AdministrateMe
  module AdminScaffold
    module Helpers
      def smart_path(member = nil)
        to                    = {}
        to[:controller]       = build_to_controller
        to[:id]               = member.to_param if member
        to[:action]           = :show           if member
        to
      end

      def build_to_controller
        to  = []
        to << self.class.namespace.gsub('/', '_').to_sym if self.class.namespace
        to << controller_name
        to.join('/')
      end

      def path_to_parent(parent, options = {})
        to              = {:action => :show, :id => parent.to_param}
        to[:controller] = unless self.class.options[:as]
          self.class.options[:parent].to_s.pluralize
        else
          self.class.options[:as].to_s
        end
        to
      end

      def model_name
        self.class.model_name
      end

      def model_class
        self.class.model_class
      end

      def parent_class
        self.class.parent_class
      end

      def parent_key
        options[:foreign_key] || "#{options[:parent]}_id".to_sym
      end

      def accepted_action?(action)
        translated_action = translated_action_name(action)
        allowed = options[:except].empty? || !options[:except].include?(translated_action)
        if allowed && options[:except_block]
          allowed = self.instance_exec(translated_action, &options[:except_block])
        end
        allowed
      end

      def get_index
        path  = "#{controller_name}_path"
        unless options[:parent].blank?
          path << "(params[:#{options[:parent].to_s}_id])"
        end
        eval(path)
      end

      def active_filter
        session[:active_filters] ? session[:active_filters][self.class.to_s] : nil
      end

      def active_combo_filters
        session[:combo_filters][self.class.to_s].keys
      end

      def combo_filters
        session[:combo_filters][self.class.to_s]
      end

      def filter_config
        self.options[:filter_config]
      end

      def show_all_records?
        !params[:all].blank? || params[:format] == 'xls'
      end

    protected

      # Simplifies action_name handling for accepted_action?()
      def translated_action_name(action)
        case action
        when :update
          :edit
        when :create
          :new
        else
          action
        end
      end
    end
  end
end

