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

describe AdminView, 'admin_file_loader' do
  include AdminView
  before do
    @controller = mock('controller')
  end

  it "should always load the default files" do
    self.should_receive(:stylesheet_link_tag).with('admin_look').and_return('A')
    self.should_receive(:stylesheet_link_tag).with('reset-fonts-grids').and_return('B')
    self.should_receive(:javascript_include_tag).with(:defaults).and_return('C')
    self.should_receive(:javascript_include_tag).with('admin_ui.js').and_return('D')
    admin_file_loader.should == 'ABCD'
  end

  it "should allow override the default files with the admin_style callback" do
    controller.stub!(:admin_style).and_return(['my-css', 'other-css'])
    self.should_receive(:stylesheet_link_tag).with('my-css').and_return('A')
    self.should_receive(:stylesheet_link_tag).with('other-css').and_return('B')
    self.stub!(:javascript_include_tag).and_return('C')
    admin_file_loader.should == 'ABCC'
  end

  it "should allow override the default files with the admin_scripts callback" do
    controller.stub!(:admin_scripts).and_return(['my-js', 'other-js'])
    self.stub!(:stylesheet_link_tag).and_return('A')
    self.should_receive(:javascript_include_tag).with('my-js').and_return('C')
    self.should_receive(:javascript_include_tag).with('other-js').and_return('D')
    admin_file_loader.should == 'AACD'
  end

  it "should allow override the default file with the admin_style callback" do
    controller.stub!(:admin_style).and_return([['my-css', {:media => 'screen'}]])
    self.should_receive(:stylesheet_link_tag).with('my-css', :media => 'screen').and_return('A')
    self.stub!(:javascript_include_tag).and_return('C')
    admin_file_loader.should == 'ACC'
  end

  def controller
    @controller
  end
end