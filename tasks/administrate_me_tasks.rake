namespace :admin do
  desc "Importar al proyecto los archivos para el admin"
  task :import_files do
    require 'railties_path'
    
    path_to_css = RAILS_ROOT + "/public/stylesheets/"
    stylesheets = Dir["./vendor/plugins/administrate_me/files/stylesheets/*.css"]
    FileUtils.cp(stylesheets, path_to_css)
    
    path_to_images = RAILS_ROOT + "/public/images/admin_ui/"
    images = Dir["./vendor/plugins/administrate_me/files/images/*.*"]
    FileUtils.cp(images, path_to_images)
    
    path_to_layouts = RAILS_ROOT + "/app/views/layouts/"
    layouts     = Dir["./vendor/plugins/administrate_me/files/layouts/*.rhtml"]
    FileUtils.cp(layouts, path_to_layouts)
    
    path_to_commons = RAILS_ROOT + "/app/views/commons/"
    commons     = Dir["./vendor/plugins/administrate_me/files/commons/*.rhtml"]
    FileUtils.cp(commons, path_to_commons) 
  end
end