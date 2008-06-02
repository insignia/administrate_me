Event.observe(window, 'load', function() { 
  var flasher = $('flasher');
  if (flasher) {
    Element.hide.delay(5, flasher);
  }
});
