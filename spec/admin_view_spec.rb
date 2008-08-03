require 'rubygems'

module ActionView
  class Base
  end
end

require File.dirname(__FILE__) + '/../lib/admin_view.rb'

describe AdminView, 'module' do
  it "should be included no ActionView::Base" do
    ActionView::Base.should include(AdminView)
  end
end

describe AdminView, 'show_section_content' do
  include AdminView
  before do
    @controller = mock('controller')
    @controller.stub!(:options).and_return({})
    @template = self
    @template.stub!(:show_section_header).and_return('header')
    @template.stub!(:show_search_form).and_return('search_form')
    @template.stub!(:show_section_body).and_return('section_body')
  end

  it "should include section header on the result" do
    show_section_content.should =~ /^header/
  end
  
  it "should include section body" do
    show_section_content.should =~ /section_body$/
  end
  
  it "should not include search form if search options are not defined" do
    show_section_content.should_not =~ /search_form/
  end
  
  it "should include search form if search options are defined" do
    @controller.stub!(:options).and_return(:search => 'field')
    show_section_content.should =~ /search_form/
  end
  
  def controller
    @controller
  end
end
