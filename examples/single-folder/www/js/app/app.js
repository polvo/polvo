
define(['genres/progressive', 'genres/triphop'], function(Progressive, TripHop) {
  var App;
  App = (function() {

    function App() {
      console.log("App created!");
      new Progressive;
      new TripHop;
    }

    return App;

  })();
  return new App;
});
