class AdminViewGenerator < Rails::Generator::NamedBase
  attr_accessor :klass, :form_type
  
  def initialize(*args)
    super
    @klass = name.classify.constantize
    @form_type = Hash.new('text_field')
    @form_type[:text] = 'text_area'
    @form_type[:boolean] = 'check_box'
    @form_type[:datetime] = 'datetime_select'
    @form_type[:date] = 'date_select'
  end

  def manifest
    record do |m|
      views_dir = File.join('app/views', name.underscore.pluralize )
      m.directory views_dir
      m.template '_form.html.erb', File.join(views_dir, "_form.html.erb")
      m.template '_list.html.erb', File.join(views_dir, "_list.html.erb")
      m.template 'show.html.erb',  File.join(views_dir, "show.html.erb")
    end
  end

end