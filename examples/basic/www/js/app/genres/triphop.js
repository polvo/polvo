
define(['app/artists/triphop/massiveattack', 'app/artists/triphop/portishead', 'app/artists/triphop/lovage'], function(MassiveAttack, Portishead, Lovage) {
  var TripHop;
  return TripHop = (function() {

    function TripHop() {
      console.log('massive attack: ' + (new MassiveAttack).constructor.name);
      console.log('portishead: ' + (new Portishead).constructor.name);
      console.log('lovage: ' + (new Lovage).constructor.name);
    }

    return TripHop;

  })();
});
