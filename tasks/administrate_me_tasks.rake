namespace :admin do
  desc "Importar al proyecto los archivos para el admin"
  task :import_files do
    require 'railties_path'
    
    path_to_css = RAILS_ROOT + "/public/stylesheets/"
    stylesheets = Dir["./vendor/plugins/administrate_me/files/stylesheets/*.css"]
    FileUtils.cp(stylesheets, path_to_css, :verbose => true)
    
    path_to_js = RAILS_ROOT + "/public/javascripts/"
    javascripts = Dir["./vendor/plugins/administrate_me/files/javascripts/*.js"]
    FileUtils.cp(javascripts, path_to_js, :verbose => true)

    path_to_images = RAILS_ROOT + "/public/images/admin_ui/"
    FileUtils.mkdir(path_to_images) unless File.exist?(path_to_images)
    images = Dir["./vendor/plugins/administrate_me/files/images/*.*"]
    FileUtils.cp(images, path_to_images, :verbose => true)
    
    path_to_layouts = RAILS_ROOT + "/app/views/layouts/"
    layouts = Dir["./vendor/plugins/administrate_me/files/layouts/*.html.erb"]
    FileUtils.cp(layouts, path_to_layouts, :verbose => true)
    
    path_to_commons = RAILS_ROOT + "/app/views/commons/"
    FileUtils.mkdir(path_to_commons) unless File.exist?(path_to_commons)
    commons = Dir["./vendor/plugins/administrate_me/files/commons/*.html.erb"]
    FileUtils.cp(commons, path_to_commons, :verbose => true) 
    puts "Los archivos necesarios fueron copiados..."
  end
end