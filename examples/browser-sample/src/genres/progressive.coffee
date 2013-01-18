KingCrimson = require 'artists/progressive/kingcrimson'
TheMarsVolta = require 'artists/progressive/themarsvolta'
Tool = require 'artists/progressive/tool'

class Progressive
  constructor:->
    console.log "\tGenre: Progressive created!"
    new KingCrimson
    new TheMarsVolta
    new Tool