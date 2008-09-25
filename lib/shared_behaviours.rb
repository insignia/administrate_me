# This are administrate_me behaviours. You can use them to test your administrate_me
# controllers.
# Here's an example:
#
#   describe ProjectsController do
#     before do
#       @mock_model_class = Project
#       @will_paginate_installed = @mock_model_class.respond_to?('paginate')
#     end
#
#     it_should_behave_like 'basic administrate_me'
#
#   end
#
# You can use the code on the example as is, just changing the model class
# assigned to the <code>@mock_model_class</code> instance variable.
#
# Also, you need to include this line on your <code>spec/spec_helper.rb</code> file:
#
#   require File.expand_path(File.dirname(__FILE__) + "/../vendor/plugins/administrate_me/lib/shared_behaviours")
#
# You might need to change the <code>administrate_me</code> folder name if you installed the
# plugin using a different name.
#
# More info about shared behaviours:
#
# - http://rspec.info/documentation/
# - http://www.robbyonrails.com/articles/2008/08/19/rspec-it-should-behave-like
#
describe 'basic administrate_me', :shared => true do

  def mock_model_instance(stubs={})
    @mock_model_instance ||= mock_model(@mock_model_class, stubs)
  end

  describe "responding to GET index" do

    it "should expose all models as @records" do
      if @will_paginate_installed
        @mock_model_class.should_receive(:paginate).with(an_instance_of(Hash)).and_return([mock_model_instance])
      else
        @mock_model_class.should_receive(:find).with(:all, an_instance_of(Hash)).and_return([mock_model_instance])
      end
      get :index
      assigns[:records].should == [mock_model_instance]
    end

    describe "with mime type of xml" do

      it "should render all models as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        if @will_paginate_installed
          @mock_model_class.should_receive(:paginate).with(an_instance_of(Hash)).and_return(models = mock("Array of models"))
        else
          @mock_model_class.should_receive(:find).with(:all, an_instance_of(Hash)).and_return(models = mock("Array of models"))
        end
        models.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET show" do

    it "should expose the requested model as @resource" do
      @mock_model_class.should_receive(:find).with("37").and_return(mock_model_instance)
      get :show, :id => "37"
      assigns[:resource].should equal(mock_model_instance)
    end

    describe "with mime type of xml" do

      it "should render the requested model as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @mock_model_class.should_receive(:find).with("37").and_return(mock_model_instance)
        mock_model_instance.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET new" do

    it "should expose a new model as @resource" do
      @mock_model_class.should_receive(:new).and_return(mock_model_instance)
      get :new
      assigns[:resource].should equal(mock_model_instance)
    end

  end

  describe "responding to GET edit" do

    it "should expose the requested model as @resource" do
      @mock_model_class.should_receive(:find).with("37").and_return(mock_model_instance)
      get :edit, :id => "37"
      assigns[:resource].should equal(mock_model_instance)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created model as @resource" do
        @mock_model_class.should_receive(:new).with({'these' => 'params'}).and_return(mock_model_instance(:save! => true))
        controller.stub!(:model_name).and_return(:resource_name)
        post :create, :resource_name => {:these => 'params'}
        assigns(:resource).should equal(mock_model_instance)
      end

      it "should redirect to the created model" do
        @mock_model_class.stub!(:new).and_return(mock_model_instance(:save! => true))
        controller.stub!(:path_to_index).and_return('/index/path')
        post :create, :resource_name => {}
        response.should redirect_to('/index/path')
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved model as @resource" do
        @mock_model_class.stub!(:new).with({'these' => 'params'}).and_return(mock_model_instance(:save! => false))
        controller.stub!(:model_name).and_return(:resource_name)
        post :create, :resource_name => {:these => 'params'}
        assigns(:resource).should equal(mock_model_instance)
      end

      it "should re-render the 'base_form' template" do
        @mock_model_class.stub!(:new).and_return(mock_model_instance(:save! => false))
        controller.stub!(:model_name).and_return(:resource_name)
        post :create, :resource_name => {}
        response.should render_template('commons/base_form')
      end

    end

  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested model" do
        @mock_model_class.should_receive(:find).with("37").and_return(mock_model_instance)
        mock_model_instance.should_receive(:attributes=).with({'these' => 'params'})
        mock_model_instance.should_receive(:save!).and_return(true)
        controller.stub!(:model_name).and_return(:resource_name)
        put :update, :id => "37", :resource_name => {:these => 'params'}
      end

      it "should expose the requested model as @resource" do
        @mock_model_class.stub!(:find).and_return(mock_model_instance(:attributes= => true))
        mock_model_instance.should_receive(:save!).and_return(true)
        put :update, :id => "1"
        assigns(:resource).should equal(mock_model_instance)
      end

      it "should redirect to the model" do
        @mock_model_class.stub!(:find).and_return(mock_model_instance(:attributes= => true))
        mock_model_instance.should_receive(:save!).and_return(true)
        controller.stub!(:path_to_element).and_return('/resource/path')
        put :update, :id => "1"
        response.should redirect_to('/resource/path')
      end

    end

    describe "with invalid params" do

      it "should update the requested model" do
        @mock_model_class.should_receive(:find).with("37").and_return(mock_model_instance)
        mock_model_instance.should_receive(:attributes=).with({'these' => 'params'})
        mock_model_instance.should_receive(:save!).and_return(false)
        controller.stub!(:model_name).and_return(:resource_name)
        put :update, :id => "37", :resource_name => {:these => 'params'}
      end

      it "should expose the model as @resource" do
        @mock_model_class.stub!(:find).and_return(mock_model_instance(:attributes= => false))
        mock_model_instance.should_receive(:save!).and_return(false)
        put :update, :id => "1"
        assigns(:resource).should equal(mock_model_instance)
      end

      it "should re-render the 'base_form' template" do
        @mock_model_class.stub!(:find).and_return(mock_model_instance(:attributes= => false))
        mock_model_instance.should_receive(:save!).and_return(false)
        put :update, :id => "1"
        response.should render_template('commons/base_form')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested model" do
      @mock_model_class.should_receive(:find).with("37").and_return(mock_model_instance)
      mock_model_instance.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "should redirect to the models list" do
      @mock_model_class.stub!(:find).and_return(mock_model_instance(:destroy => true))
      controller.stub!(:path_to_index).and_return('/index/path')
      delete :destroy, :id => "1"
      response.should redirect_to('/index/path')
    end

  end

end
