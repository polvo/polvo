(function() {

  define(['app/artists/progressive/kingcrimson', 'app/artists/progressive/themarsvolta', 'app/artists/progressive/tool'], function(KingCrimson, TheMarsVolta, Tool) {
    var Progressive;
    return Progressive = (function() {

      function Progressive() {
        console.log("\tGenre: Progressive created!");
        new KingCrimson;
        new TheMarsVolta;
        new Tool;
      }

      return Progressive;

    })();
  });

}).call(this);
