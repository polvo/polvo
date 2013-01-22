Progressive = require 'app/genres/progressive'
TripHop = require 'app/genres/triphop'
$ = require ':jquery'

class App
  constructor:->
    console.log 'progressive: ' + (new Progressive).constructor
    console.log 'triphop: ' + (new TripHop).constructor
    console.log 'jquery: ' + $

new App