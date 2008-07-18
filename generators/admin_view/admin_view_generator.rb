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
      parts = name.split('/')
      parts.unshift 'app', 'views'
      parts << (parts.pop.underscore.pluralize)
      views_dir = File.join(*parts)
      m.directory views_dir
      m.template '_form.html.erb', File.join(views_dir, "_form.html.erb")
      m.template '_list.html.erb', File.join(views_dir, "_list.html.erb")
      m.template 'show.html.erb',  File.join(views_dir, "show.html.erb")
      if parent = actions.map {|action| action =~ /^parent:(.*)/; $1}.compact.first
        parts << '..' << parent.split('/')
        m.template '_context.html.erb',  File.join(parts.flatten, "_context.html.erb")
      end
    end
  end

end
