
define(['app/artists/triphop/massiveattack', 'app/artists/triphop/portishead', 'app/artists/triphop/lovage'], function(MassiveAttack, Portishead, Lovage) {
  var TripHop;
  return TripHop = (function() {

    function TripHop() {
      console.log('massive attack: ' + (new MassiveAttack).constructor);
      console.log('portishead: ' + (new Portishead).constructor);
      console.log('lovage: ' + (new Lovage).constructor);
    }

    return TripHop;

  })();
});
