class AdminViewGenerator < Rails::Generator::NamedBase
  
  def initialize(*args)
    super
  end

  def manifest
    record do |m|
      views_dir = File.join('app/views', name.downcase.pluralize )
      m.directory views_dir
      m.template '_form.html.erb', File.join(views_dir, "_form.html.erb")
      m.template '_list.html.erb', File.join(views_dir, "_list.html.erb")
      m.template 'show.html.erb',  File.join(views_dir, "show.html.erb")
    end
  end

end