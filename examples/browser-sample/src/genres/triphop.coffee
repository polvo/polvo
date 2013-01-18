MassiveAttack = require 'artists/triphop/massiveattack'
Portishead = require 'artists/triphop/portishead'
Lovage = require 'artists/triphop/lovage'

class TripHop
  constructor:->
    console.log "\tGenre: TripHop created!"
    new MassiveAttack
    new Portishead
    new Lovage