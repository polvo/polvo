var  = {'app':{},'artists':{},'genres':{}};


define('artists/triphop/massiveattack', [], function() {
  var MassiveAttack;
  return MassiveAttack = (function() {

    function MassiveAttack() {
      console.log("\t\tArtist: MassiveAttack created!");
    }

    return MassiveAttack;

  })();
});

define('artists/triphop/portishead', [], function() {
  var Portishead;
  return Portishead = (function() {

    function Portishead() {
      console.log("\t\tArtist: Portishead created!");
    }

    return Portishead;

  })();
});

define('artists/triphop/lovage', [], function() {
  var Lovage;
  return Lovage = (function() {

    function Lovage() {
      console.log("\t\tArtist: Lovage created!");
    }

    return Lovage;

  })();
});

define('artists/progressive/kingcrimson', [], function() {
  var KingCrimson;
  return KingCrimson = (function() {

    function KingCrimson() {
      console.log("\t\tArtist: KingCrimson created!");
    }

    return KingCrimson;

  })();
});

define('genres/triphop', ['artists/triphop/massiveattack', 'artists/triphop/portishead', 'artists/triphop/lovage'], function(MassiveAttack, Portishead, Lovage) {
  var TripHop;
  return TripHop = (function() {

    function TripHop() {
      console.log("\tGenre: TripHop created!");
      new MassiveAttack;
      new Portishead;
      new Lovage;
    }

    return TripHop;

  })();
});

define('artists/progressive/themarsvolta', [], function() {
  var TheMarsVolta;
  return TheMarsVolta = (function() {

    function TheMarsVolta() {
      console.log("\t\tArtist: TheMarsVolta created!");
    }

    return TheMarsVolta;

  })();
});

define('artists/progressive/tool', [], function() {
  var Tool;
  return Tool = (function() {

    function Tool() {
      console.log("\t\tArtist: Tool created!");
    }

    return Tool;

  })();
});

define('genres/progressive', ['artists/progressive/kingcrimson', 'artists/progressive/themarsvolta', 'artists/progressive/tool'], function(KingCrimson, TheMarsVolta, Tool) {
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

define('app/app', ['genres/progressive', 'genres/triphop'], function(Progressive, TripHop) {
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
