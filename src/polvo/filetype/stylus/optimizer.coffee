require('source-map-support').install()

Loader = require './optimizer/loader'

module.exports = class Optimizer
  
  constructor:( @polvo, @cli, @config, @tree )->
    @loader = new Loader @polvo, @cli, @config, @tree, @

  optimize_for_development:->
    do @loader.write_loader

  optimize_for_release:->
    