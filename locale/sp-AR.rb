I18n.store_translations :'en-US',
  :yes => 'SI',
  :no  => 'NO',
  :views => {
    :prev => 'Anterior',
    :next => 'Siguiente',
    :logout => 'Salir',
    :save_this_changes => 'Guardar estos cambios',
    :cancel => 'Cancelar',
    :add_new_record => 'Agregar nuevo registro',
    :default_title => 'Administración',
    :download_to_excel => "Descargar a Excel",
    :see_more => 'ver más...',
    :edit_this_record => 'Editar este registro',
    :delete_confirm => 'El registro será eliminado definitivamente. ¿Desea continuar?',
    :delete_this_record => 'Eliminar este registro',
    :filter_records_by => 'Filtrar registros por...',
    :admin => 'administrar',
    :empty_dataset => 'No hay registros cargados',
    :new_record => "Nuevo {{model}}",
    :edit_record => "Editando un {{model}}",
    :back => 'Volver',
    :search_prompt => 'Búsqueda (tipee la palabra que busca)'
  },
  :messages => {
    :create_success => 'El registro fue creado exitosamente',
    :save_success => 'Los cambios fueron guardados exitosamente',
    :destroy_success => 'El registro fue eliminado exitosamente.',
    :search_message => "se encontraron {{count}} resultados con \"<b>{{search_key}}</b>\"",
    :missing_parent => "No existe el padre del elemento solicitado"
  },
  :errors => {
    :modules_not_defined => "Debe definir los módulos para la aplicación. Ver documentacion de AdministrateMe::Base#set_module para mayor información",
    :exception_on_save => "Ocurrió una exception al salvar el registro: {{message}}"
  }
