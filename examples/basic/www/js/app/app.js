
define(['app/genres/progressive', 'app/genres/triphop', ':jquery'], function(Progressive, TripHop) {
  var App;
  App = (function() {

    function App() {
      console.log('progressive: ' + (new Progressive).constructor.name);
      console.log('triphop: ' + (new TripHop).constructor.name);
      console.log('jquery: ' + $);
      console.log('APP INITIALIZED!');
    }

    return App;

  })();
  return new App;
});
