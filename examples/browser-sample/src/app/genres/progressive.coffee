KingCrimson = require 'app/artists/progressive/kingcrimson'
TheMarsVolta = require 'app/artists/progressive/themarsvolta'
Tool = require 'app/artists/progressive/tool'

class Progressive
  constructor:->
    console.log "\tGenre: Progressive created!"
    new KingCrimson
    new TheMarsVolta
    new Tool