Progressive = require 'app/genres/progressive'
TripHop = require 'app/genres/triphop'
$ = require ':jquery'

class App
  constructor:->
    console.log 'progressive: ' + (new Progressive).constructor.name
    console.log 'triphop: ' + (new TripHop).constructor.name
    console.log 'jquery: ' + $

    console.log 'APP INITIALIZED!'

new App