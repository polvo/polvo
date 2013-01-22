(function() {

  define(['app/artists/triphop/massiveattack', 'app/artists/triphop/portishead', 'app/artists/triphop/lovage'], function(MassiveAttack, Portishead, Lovage) {
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

}).call(this);
