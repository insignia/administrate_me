namespace(:admin) do        
  desc "import administrate_me files into current project"
  task :import_files do
    require 'railties_path'
    include ImportMethods
    
    css
    js
    images
    layout
    commons
    initializers
  end
  
  module ImportMethods    
    FILES_ROOT = "./vendor/plugins/administrate_me/files"
    
    def css
      files_to_copy = Dir["#{FILES_ROOT}/stylesheets/*.css"]
      files_to_copy.reject! {|filename| File.basename(filename) == 'admin_custom.css'}
      FileUtils.cp( files_to_copy,
                    RAILS_ROOT + "/public/stylesheets/", :verbose => true )
    end
    
    def js
      FileUtils.cp( Dir["#{FILES_ROOT}/javascripts/*.js"],
                    RAILS_ROOT + "/public/javascripts/", :verbose => true )
    end
    
    def images
      path_to_images = RAILS_ROOT + "/public/images/admin_ui/"
      FileUtils.mkdir(path_to_images) unless File.exist?(path_to_images)
      FileUtils.cp( Dir["#{FILES_ROOT}/images/*.*"], path_to_images, 
                    :verbose => true )
    end
    
    def layout
      FileUtils.cp( Dir["#{FILES_ROOT}/layouts/*.html.erb"],
                    RAILS_ROOT + "/app/views/layouts/", :verbose => true )
    end
    
    def commons
      path_to_commons = RAILS_ROOT + "/app/views/commons/"
      FileUtils.mkdir(path_to_commons) unless File.exist?(path_to_commons)
      files_to_copy = Dir["#{FILES_ROOT}/commons/*.html.erb"]
      files_to_copy.reject! {|filename| (File.basename(filename) == '_session.html.erb' && File.exist?("#{path_to_commons}_session.html.erb")) }
      FileUtils.cp( files_to_copy, path_to_commons, 
                    :verbose => true )
    end
    
    def initializers
      FileUtils.cp( "#{FILES_ROOT}/initializers/administrate_me.rb",
                    "./config/initializers", :verbose => true )
    end
  end
  
end

