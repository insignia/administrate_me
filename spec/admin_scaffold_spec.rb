#require '../lib/admin_scaffold.rb'
require File.dirname(__FILE__) + '/../lib/admin_scaffold.rb'

describe AdministrateMe::AdminScaffold::InstanceMethods do
  
  before do 
    @controller = Object.new
    @controller.include AdministrateMe::AdminScaffold::InstanceMethods
    @controller.stub!(:controller_name).and_return('persons')
    @controller.stub!(:options).and_return({})
  end
  
  describe "path_to_index" do
    
    before do 
      @element = mock('Element')
      @path = '/path_to_element/id'
    end
    
    it "should call and return person_path" do
      @controller.should_receive(:person_path).with(@element).and_return(@path)
      @controller.path_to_element(@element).should == @path
    end
    
  end
  
end