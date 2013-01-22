MassiveAttack = require 'app/artists/triphop/massiveattack'
Portishead = require 'app/artists/triphop/portishead'
Lovage = require 'app/artists/triphop/lovage'

class TripHop
  constructor:->
    console.log 'massive attack: ' + (new MassiveAttack).constructor
    console.log 'portishead: ' + (new Portishead).constructor
    console.log 'lovage: ' + (new Lovage).constructor