require 'rubygems'
require 'activesupport'
require File.dirname(__FILE__) + '/../lib/admin_scaffold.rb'

class ControllerClass
  include AdministrateMe::InstanceMethods
end

describe AdministrateMe::InstanceMethods, 'with persons controller' do
  
  before do 
    @controller = ControllerClass.new
    ControllerClass.stub!(:namespace).and_return(nil)
    @controller.stub!(:controller_name).and_return('persons')
    @controller.stub!(:options).and_return({})
  end
  
  describe "create_path" do
    
    before do 
      @element = mock('Element')
      @path = '/path_to_element/id'
      @controller_name = 'person'
    end
    
    it "should call element path and return its value" do
      @controller.should_receive(:person_path).with(@element).and_return(@path)
      @controller.create_path(@controller_name, @element, nil, nil).should == @path
    end
    
    it "should call element path with prefix and return its value" do
      @controller.should_receive(:edit_person_path).with(@element).and_return(@path)
      @controller.create_path(@controller_name, @element, nil, nil, :prefix => :edit).should == @path
    end
    
    it "should call element path with namespace and return its value" do
      ControllerClass.stub!(:namespace).and_return(:admin)
      @controller.should_receive(:admin_person_path).with(@element).and_return(@path)
      @controller.create_path(@controller_name, @element, :admin, nil).should == @path
    end
    
    it "should call element path with parent and return its value" do
      company = mock('Company')
      @controller.should_receive(:company_person_path).with(company, @element).and_return(@path)
      @controller.create_path(@controller_name, @element, nil, company, :parent => :company).should == @path
    end
    
  end
  
end