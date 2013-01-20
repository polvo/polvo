MassiveAttack = require 'app/artists/triphop/massiveattack'
Portishead = require 'app/artists/triphop/portishead'
Lovage = require 'app/artists/triphop/lovage'

class TripHop
  constructor:->
    console.log "\tGenre: TripHop created!"
    new MassiveAttack
    new Portishead
    new Lovage