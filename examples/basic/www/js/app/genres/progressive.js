
define(['app/artists/progressive/kingcrimson', 'app/artists/progressive/themarsvolta', 'app/artists/progressive/tool'], function(KingCrimson, TheMarsVolta, Tool) {
  var Progressive;
  return Progressive = (function() {

    function Progressive() {
      console.log('king crimson: ' + (new KingCrimson).constructor);
      console.log('the mars volta: ' + (new TheMarsVolta).constructor);
      console.log('tool: ' + (new Tool).constructor);
    }

    return Progressive;

  })();
});
