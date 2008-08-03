require File.dirname(__FILE__) + '/../lib/administrate_me.rb'
#require File.dirname(__FILE__) + '/../lib/admin_scaffold.rb'

module AdministrateMe
  module AdminScaffold
    module InstanceMethods

    end
  end
end

require 'rubygems'
require 'actionpack'
require 'action_controller'
require 'activesupport'

ActionController::Base.extend AdministrateMe::ClassMethods

class FooController < ActionController::Base
end

describe AdministrateMe do
  before(:each) do
  end

  describe "called on a controller" do

    def call_administrate_me(&block)
      FooController.send(:administrate_me, &block)
    end

    it "should be able to call administrate_me without passing a block" do
      FooController.stub!(:build)
      lambda do
        call_administrate_me
      end.should_not raise_error
    end

    it "should extend the controller with AdministrateMe::ClassMethods::Base" do
      FooController.stub!(:build)
      FooController.should_receive(:extend).with(AdministrateMe::ClassMethods::Base)
      call_administrate_me
    end

    it "should yield a config object" do
      @config = mock('config')
      AdministrateMe::ClassMethods::AdministrateMeConfig.stub!(:new).and_return(@config)
      #FIXME: Look for this rpsec patch to be applied: http://rspec.lighthouseapp.com/projects/5645-rspec/tickets/100-11949-amp-quot-should_yield-amp-quot-or-amp-quot-should-raise_error-myspecificerror-amp-quot-equivalent-for-yields#ticket-100-2
      pending "There is no yield_with() matcher yet" do
        lambda do
          call_administrate_me
        end.should yield_with(@config)
      end
    end

    it "should call build the administrate_me configuration with the created config object" do
      config = mock('config')
      AdministrateMe::ClassMethods::AdministrateMeConfig.stub!(:new).and_return(config)
      FooController.should_receive(:build).with(config)
      call_administrate_me
    end


  end
end

