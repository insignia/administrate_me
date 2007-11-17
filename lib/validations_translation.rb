module ActiveRecord
 class Errors
   begin
     @@default_error_messages = {:inclusion => "es obligatorio",
         :exclusion => "es campo reservado",
         :invalid => "no es válido",
         :confirmation => "no coincide la confirmación",
         :accepted => "debe ser aceptado",
         :empty => "no puede estar vacío",
         :blank => 'no puede estar en blanco',
         :too_long => "es demasiado largo (%d caracteres como máximo)",
         :too_short => "es demasiado corto (%d caracteres como mínimo)",
         :wrong_length => "debe tener %d caracteres",
         :taken => "ya existe",
         :not_a_number => "no es un número" }
   end
 end
end
