KingCrimson = require 'app/artists/progressive/kingcrimson'
TheMarsVolta = require 'app/artists/progressive/themarsvolta'
Tool = require 'app/artists/progressive/tool'

class Progressive
  constructor:->
    console.log 'king crimson: ' + (new KingCrimson).constructor
    console.log 'the mars volta: ' + (new TheMarsVolta).constructor
    console.log 'tool: ' + (new Tool).constructor