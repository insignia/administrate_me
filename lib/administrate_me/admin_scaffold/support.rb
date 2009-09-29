module AdministrateMe
  module AdminScaffold
    module Support
      def create_path(controller_name, element, namespace, parent, options = {})
        parts = []
        # add prefix
        parts << options[:prefix] if options[:prefix]
        # add namespace
        parts << namespace.gsub('/', '_') if namespace
        # add parent
        parts << options[:parent] if options[:parent]
        # add controller
        parts << controller_name
        #
        parts << 'path'
        helper_name = parts.join('_')
        ids = [element]
        ids.unshift parent unless parent.blank?
        send(helper_name, *ids)
      end

      def default_style
        ['css-reset', 'admin_look', 'ame-backport', 'admin_custom', ['admin_look_print', {:media => 'print'}]]
      end

      def default_js
        [:defaults, 'admin_ui.js']
      end
    end
  end
end

