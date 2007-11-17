/* fade flashes automatically */
Event.observe(window, 'load', function() { 
  $A(document.getElementsByClassName('alert')).each(function(o) {
    o.opacity = 100.0
    Effect.Fade(o, {duration: 3.5})
  });
});