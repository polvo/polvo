require('source-map-support').install()

fs = require "fs"
path = require "path"
colors = require 'colors'

Cli = require './polvo/cli'
Config = require './polvo/config'
Tentacle = require './polvo/core/tentacle'

ProjectGen = require './polvo/generators/project'
ConfigGen = require './polvo/generators/config'

{log,debug,warn,error} = require './polvo/utils/log-util'

module.exports = class Polvo

  @options = null 
  @skip_initial_compile = false

  polvo_base: null
  config: null
  tentacles: null

  # variable - before filter container
  before_compile: null

  constructor:( basedir, options = null, skip_initial_compile = false )->

    @polvo_base = path.dirname __dirname

    @options = options
    @skip_initial_compile = skip_initial_compile

    @basepath = path.resolve( basedir || "." )

    global.cli = @cli = new Cli options
    # console.log '::: ', global.cli

    # increments basepath if some path is given for args -n, -i, -c, -w, -r
    # just one of these could have a path, so only the first found will be
    # considered.
    for flag in ('nicwr'.split '')
      if (typeof (base = @cli.argv[flag]) is 'string')
        @basepath = path.resolve base
        break

    # injecting options into @cli.argv to maintain interoperability
    if @options?
      @cli.argv[k] = v for k, v of @options

    # printing version
    if @cli.argv.v
      filepath = path.join __dirname, "./../package.json"
      contents = fs.readFileSync filepath, "utf-8"
      schema = JSON.parse contents
      return log schema.version

    # scaffolding basic structure for new projects
    else if @cli.argv.n
      new ProjectGen( @basepath ).create @cli.argv.n

    # initializing a polvo file template into an existent project
    else if @cli.argv.i
      new ConfigGen( @basepath ).create()

    # compile / release / watch / serve
    else if (@cli.argv.c or @cli.argv.r or @cli.argv.w or @cli.argv.s)
      @init()

      unless skip_initial_compile
        if (@cli.argv.c or @cli.argv.r or @cli.argv.w)
          @compile()

    # showing help screen
    else
      return log @cli.opts.help()

  init:->
    @tentacles = []
    @config = new Config @ #, @options, @skip_initial_compile
    for conf in @config.confs
      @tentacles.push new Tentacle @, @cli, conf

  # can be called by apps using polvo as lib, and compile the project with
  # options to inject header and footer code which must to be in coffee as well
  # and will be compiled together the app.
  compile:( header_code = "", footer_code = "" )->
    for tentacle in @tentacles
      if @cli.argv.c? or @cli.argv.w?
        tentacle.compile header_code, footer_code
      else if @cli.argv.r
        tentacle.optimize header_code, footer_code

    if process.send
      process.send channel: null, msg: 'status.compiled'

  # resets the polvo completely - specially used when the `polvo.coffee`
  # config file is edited :)
  reset:( options )->
    config.reset() for config in @config
    @options[ key ] = val for val, key of options if options?
    @init true
    @compile()