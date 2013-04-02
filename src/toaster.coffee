require('source-map-support').install()

fs = require "fs"
path = require "path"
exec = (require "child_process").exec
colors = require 'colors'

Cli = require './toaster/cli'
Config = require './toaster/config'
Toast = require './toaster/toast'

ProjectGen = require './toaster/generators/project'
ConfigGen = require './toaster/generators/config'

{log,debug,warn,error} = require './toaster/utils/log-util'

module.exports = class Toaster

  @options = null 
  @skip_initial_compile = false

  toaster_base: null
  toasts: null
  # variable - before filter container
  before_compile: null

  constructor:( basedir, options = null, skip_initial_compile = false )->

    @toaster_base = path.dirname __dirname

    @options = options
    @skip_initial_compile = skip_initial_compile

    @basepath = path.resolve( basedir || "." )

    @cli = new Cli options

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
      filepath = path.join __dirname, "../../package.json"
      contents = fs.readFileSync filepath, "utf-8"
      schema = JSON.parse contents
      return log schema.version

    # scaffolding basic structure for new projects
    else if @cli.argv.n
      new ProjectGen( @basepath ).create @cli.argv.n

    # initializing a toaster file template into an existent project
    else if @cli.argv.i
      new ConfigGen( @basepath ).create()

    # injecting namespace declarations
    # else if @cli.argv.ns
    #   @toast = new toaster.Config @
    #   new toaster.misc.InjectNS @toast.compileers

    # auto run mode
    # else if @cli.argv.a and not @cli.argv.c
    #   msg = "Option -a can't work without -w, usage: \n"
    #   msg += "\ttoaster -wa"
    #   error msg

    # compile / release / watch / serve
    else if (@cli.argv.c or @cli.argv.r or @cli.argv.w or @cli.argv.s)
      @initialize_toasters()

      unless skip_initial_compile
        if (@cli.argv.c or @cli.argv.r or @cli.argv.w)
          @compile()

    # showing help screen
    else
      return log @cli.opts.help()

  initialize_toasters:( compile_at_startup )->
    @toasts = []
    @config = new Config @ #, @options, @skip_initial_compile
    for conf in @config.confs
      @toasts.push new Toast @, @cli, conf

  # can be called by apps using toaster as lib, and compile the project with
  # options to inject header and footer code which must to be in coffee as well
  # and will be compiled together the app.
  compile:( header_code = "", footer_code = "" )->
    for toast in @toasts
      if @cli.argv.c? or @cli.argv.w?
        toast.compile header_code, footer_code
      else if @cli.argv.r
        toast.optimize header_code, footer_code

  # resets the toaster completely - specially used when the `toaster.coffee`
  # config file is edited :)
  reset:( options )->
    toast.reset() for toast in @toasts
    @options[ key ] = val for val, key of options if options?
    @initialize_toasters true
    @compile()