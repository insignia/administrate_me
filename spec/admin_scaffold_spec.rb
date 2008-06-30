require 'rubygems'
require 'activesupport'
require File.dirname(__FILE__) + '/../lib/admin_scaffold.rb'

class ControllerClass
  include AdministrateMe::AdminScaffold::InstanceMethods
end

describe AdministrateMe::AdminScaffold::InstanceMethods, 'with persons controller' do
  
  before do 
    @controller = ControllerClass.new
    ControllerClass.stub!(:namespace).and_return(nil)
    @controller.stub!(:controller_name).and_return('persons')
    @controller.stub!(:options).and_return({})
  end
  
  describe "path_to_index" do
    
    before do 
      @element = mock('Element')
      @path = '/path_to_element/id'
    end
    
    it "should call element path and return its value" do
      @controller.should_receive(:person_path).with(@element).and_return(@path)
      @controller.path_to_element(@element).should == @path
    end
    
    it "should call element path with prefix and return its value" do
      @controller.should_receive(:edit_person_path).with(@element).and_return(@path)
      @controller.path_to_element(@element, :prefix => :edit).should == @path
    end
    
    it "should call element path with namespace and return its value" do
      ControllerClass.stub!(:namespace).and_return(:admin)
      @controller.should_receive(:admin_person_path).with(@element).and_return(@path)
      @controller.path_to_element(@element).should == @path
    end
    
    it "should call element path with parent when parent passed as a parameter and return its value" do
      company = mock('Company')
      @controller.instance_variable_set("@parent", company)
      @controller.should_receive(:company_person_path).with(company, @element).and_return(@path)
      @controller.path_to_element(@element, :parent => :company).should == @path
    end
    
    it "should call element path with parent when parent is defined on the controller and return its value" do
      company = mock('Company')
      @controller.instance_variable_set("@parent", company)
      @controller.stub!(:options).and_return({:parent => :company})
      @controller.should_receive(:company_person_path).with(company, @element).and_return(@path)
      @controller.path_to_element(@element).should == @path
    end
    
  end
  
end