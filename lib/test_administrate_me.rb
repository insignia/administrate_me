# Test an administrate_me controller. This tester helper call all the
# seven restful actions to check they're all working fine. You'll got to
# have your fixtures for this test helper to work.
module TestAdministrateMe

  module ClassMethods

    class TestOptions
      attr_accessor :params
      def initialize
        @params = {}
      end

      def set_params(action, options = {})
        @params[action] = options
      end
    end

    # ==== Example
    #
    #   class ProductsControllerTest < Test::Unit::TestCase
    #     fixtures :products
    #     test_administrate_me
    #   end
    #
    # Parameters can also be passed to different actions when needed to
    # make models validate.
    #
    #   class ProductosControllerTest < ActionController::TestCase
    #     tests ProductosController
    #     fixtures :productos
    #     test_administrate_me do |t|
    #       t.set_params :create, :product => {:name => "Product Name"}
    #     end
    #   end
    #
    def test_administrate_me(options = {})
      @options = options
      @test_options = TestOptions.new
      yield test_options if block_given?
      include TestAdministrateMe::InstanceMethods
    end

    def options
      @options
    end

    def test_options
      @test_options
    end

  end

  module InstanceMethods

    def my_setup
      @model_name  = @controller.model_name
      @model_class = @controller.model_class
      @model_first = @model_class.find(:first)
      if parent = @controller.options[:parent]
        @parent = @model_first.send(parent)
        assert @parent, "Fixtures records have to have parents assigned to be able to run the tests."
      end
    end

    def extra_params(action)
      cls = self.class
      params = cls.test_options.params[action] || {}
      params.merge!(:"#{@controller.options[:parent]}_id" => @parent.id) if @parent
      params
    end

    def test_should_get_index
      my_setup
      get :index, extra_params(:index)
      assert_response :success
      assert assigns(:records)
    end

    def test_should_get_new
      my_setup
      test_if_accepted(:new) do
        get :new, extra_params(:new)
        assert_response :success
      end
    end

    def test_should_create
      my_setup
      test_if_accepted(:create) do
        old_count = @model_class.count
        params = {@model_name.to_sym => { }}
        post :create, params.merge(extra_params(:create))
        assert assigns(:resource)
        assert assigns(:resource).valid?, "Created record is invalid."
        assert_equal old_count + 1, @model_class.count
        assert_redirected_to :action => 'index'
      end
    end

    def test_should_show
      my_setup
      test_if_accepted(:show) do
        test_with_fixtures(:test_should_show) do
          get :show, {:id => @model_first.id}.merge(extra_params(:show))
          assert_response :success
        end
      end
    end

    def test_should_get
      my_setup
      test_if_accepted(:edit) do
        test_with_fixtures(:test_should_get) do
          get :edit, {:id => @model_first.id}.merge(extra_params(:edit))
          assert_response :success
        end
      end
    end

    def test_should_update
      my_setup
      test_if_accepted(:update) do
        test_with_fixtures(:test_should_update) do
          params = {:id => @model_first.id, @model_name.to_sym => { }}
          put :update, params.merge(extra_params(:update))
          assert_redirected_to :action => 'show', :id => assigns(:resource)
        end
      end
    end

    def test_should_destroy
      my_setup
      test_if_accepted(:destroy) do
        test_with_fixtures(:test_sould_destroy) do
          old_count = @model_class.count
          params = {:id => @model_first.id}
          delete :destroy, params.merge(extra_params(:destroy))
          assert_equal old_count-1, @model_class.count
          assert_redirected_to @controller.path_to_index
        end
      end
    end

    def test_if_accepted(a_name)
      if @controller.accepted_action?(a_name)
        yield
      else
        assert_raises ActionController::UnknownAction, "Action #{a_name} shouldn't be able to be used" do
          case a_name
          when :destroy
            delete a_name, :id => 0
          when :index
            get a_name
          when :new, :show, :edit
            get a_name, :id => 0
          when :create
            post a_name
          when :update
            put a_name, :id => 0
          end
        end
      end
    end

    def test_with_fixtures(caller)
      if @model_first
        yield
      else
        assert false, "#{caller}: Can't test correctly, there are no fixtures records."
      end
    end

  end

end

Test::Unit::TestCase.extend TestAdministrateMe::ClassMethods
