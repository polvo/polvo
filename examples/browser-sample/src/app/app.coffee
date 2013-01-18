Progressive = require 'genres/progressive'
TripHop = require 'genres/triphop'

class App
  constructor:->
    console.log "App created!"
    new Progressive
    new TripHop

new App