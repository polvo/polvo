
define(['app/genres/progressive', 'app/genres/triphop', ':jquery'], function(Progressive, TripHop) {
  var App;
  App = (function() {

    function App() {
      console.log('progressive: ' + (new Progressive).constructor);
      console.log('triphop: ' + (new TripHop).constructor);
      console.log('jquery: ' + $);
    }

    return App;

  })();
  return new App;
});
