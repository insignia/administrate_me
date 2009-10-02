module AdministrateMe
  module AdminScaffold
    module Internal

      protected

        def associate_resource_to_parent
          params[model_name.to_sym][parent_key_param] = @parent.id if @parent
        end

        def parent_key_param
          parent_key.to_sym
        end

        def get_resource
          if %w{show edit update destroy}.include?(self.action_name) && accepted_action?(self.action_name)
            @resource = model_class.find(params[:id])
          end
        end

        def habtm_callback
          options[:habtms].each do |habtm|
            params[model_name.to_sym]["#{habtm.to_s.singularize}_ids".to_sym] ||= []
          end
        end

        def if_available(action)
          if self.accepted_action?(action)
            yield
          else
            raise ActionController::UnknownAction
          end
        end

        def save_model
          begin
            model_class.transaction do
              call_callback           'before', 'save'
              call_callback_on_action 'before', 'create'
              call_callback_on_action 'before', 'update'
              if @success = @resource.save!
                call_callback           'after', 'save'
                call_callback_on_action 'after', 'create'
                call_callback_on_action 'after', 'update'
              end
            end
          rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
            logger.error(I18n.t('errors.exception_on_save', :message => $!))
            @success = false
          end
        end

        # will execute the callback only when the controller executes the
        # specific action.
        def call_callback_on_action(hook, actions)
          actions_array = [*actions]
          call_callback(hook, actions_array.join('_and_')) if actions_array.include?(action_name.to_sym)
        end

        # will execute a callback
        def call_callback(hook, action)
          method_name = "#{hook}_#{action}"
          send(method_name) if respond_to?(method_name)
        end

        def get_parent
          if parent = options[:parent]
            begin
              parent_id_key = options[:as] ? options[:as] : options[:parent]
              @parent = parent_class.find(params[:"#{parent_id_key}_id"])
            rescue ActiveRecord::RecordNotFound
              flash[:error] = I18n.t('messages.missing_parent')
              #FIXME: Where this case should redirect_to ?
              redirect_to ''
              return false
            end
          end
        end

        def set_active_filter
          session[:active_filters] ||= {}
          session[:combo_filters] ||= {}
          session[:combo_filters][self.class.to_s] ||= {}
          if params[:filter]
            session[:active_filters][self.class.to_s] = params[:filter] != 'none' ? params[:filter] : nil
          end
          if params[:combo_filter]
            session[:combo_filters][self.class.to_s][params[:combo_filter]] = !params[:combo_value].blank? ? params[:combo_value] : nil
          end
        end

        def generate_url
          html  = "url("
          unless options[:parent].blank?
            html << "@resource.send(:#{options[:parent]}_id), "
          end
          html << "@resource)"
          html
        end

        def call_before_render
          before_render if respond_to?('before_render')
          call_callback_on_action :before_render, :new
          call_callback_on_action :before_render, :create
          call_callback_on_action :before_render, [:new, :create]
          call_callback_on_action :before_render, :edit
          call_callback_on_action :before_render, :update
          call_callback_on_action :before_render, [:edit, :update]
          before_render_with_form if [:new, :create, :edit, :update].include?(action_name.to_sym) && respond_to?('before_render_with_form')
          call_callback_on_action :before_render, :index
          call_callback_on_action :before_render, :show
          call_callback_on_action :before_render, :destroy
        end

    end
  end
end

