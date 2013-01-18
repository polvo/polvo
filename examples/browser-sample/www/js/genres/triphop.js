
define(['artists/triphop/massiveattack', 'artists/triphop/portishead', 'artists/triphop/lovage'], function(MassiveAttack, Portishead, Lovage) {
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
