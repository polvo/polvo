Progressive = require 'app/genres/progressive'
TripHop = require 'app/genres/triphop'

class App
  constructor:->
    console.log "App created!"
    new Progressive
    new TripHop

new App