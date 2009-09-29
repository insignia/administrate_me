module AdministrateMe
  module AdminScaffold
    module InstanceMethods
      include AdministrateMe::AdminScaffold::Actions
      include AdministrateMe::AdminScaffold::Listing
      include AdministrateMe::AdminScaffold::Helpers
      include AdministrateMe::AdminScaffold::Internal
    end
  end

  module InstanceMethods
    include AdministrateMe::AdminScaffold::Support
  end
end

