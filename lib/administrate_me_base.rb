module AdministrateMeBase
  # El método set_module toma como parámetros el nombre de módulo a definir y 
  # opcionalmente un hash de opciones. El hash de opciones permite reemplazar 
  # los siguientes valores por defecto:
  #   :caption = Nombre a mostrar en la pestaña. Por defecto se toma el nombre
  #    del módulo en formato "humanized". 
  #   :url = Dirección del enlace en la pestaña. Por defecto se crea un
  #    enlace al index del controller con nombre igual al del módulo. 
  # Ej:
  #   set_module :productos, :caption => 'Articulos', :url => activos_productos_url()
  #
  def set_module(name, options = {})
    self.ame_modules ||= []
    self.ame_modules << administrate_me_compose_module(name, options)
  end

  def administrate_me_compose_module(name, options = {})
    {
      :name => name, 
      :caption => options[:caption] || name.to_s.humanize,
      :url => options[:url] || {:controller => "#{name.to_s.pluralize}"}
    }
  end
end
