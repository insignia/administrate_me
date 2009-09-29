require 'ostruct'
require 'administrate_me'
require 'admin_scaffold'
require 'admin_view'
require 'rspec_matchers'
require 'merge_conditions_backport'

ActionController::Base.extend AdministrateMeBase
ActionController::Base.extend AdministrateMe::ClassMethods
ActionController::Base.send :include, AdministrateMe::InstanceMethods
class ActionController::Base
  superclass_delegating_accessor :ame_modules
end

Mime.send(:remove_const, :XLS) rescue NameError
Mime::Type.register "application/vnd.ms-excel", :xls

