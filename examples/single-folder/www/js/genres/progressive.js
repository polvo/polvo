
define(['artists/progressive/kingcrimson', 'artists/progressive/themarsvolta', 'artists/progressive/tool'], function(KingCrimson, TheMarsVolta, Tool) {
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
