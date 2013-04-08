require('source-map-support').install()

# requires
fs = require "fs"
fsu = require "fs-util"
path = require "path"

colors = require 'colors'
cs = require "coffee-script"

CoffeeConfig = require './filetype/coffee/config'

{log,debug,warn,error} = require './utils/log-util'



module.exports = class Config
  confs: null

  constructor: (@polvo) ->
    @basepath = @polvo.basepath
    @confs = []

    @init()

  init:->
    # if config is json
    if (config = @polvo.cli.argv["config"])?
      config = JSON.parse( config ) unless config instanceof Object
      @tentacle item for item in ( [].concat config )
      return

    # otherwise if it's file, evaluates it's path
    config_file = @polvo.cli.argv["config-file"]
    filepath = config_file || path.join @basepath, "polvo.coffee"

    # if file doesn't exist
    unless fs.existsSync filepath

      # rise and error and aborts
      msg = "Config file not found: #{filepath.yellow}\n"
      msg += "Try running:".white + " polvo -i".green
      msg += " or type".white + " #polvo -h'".green
      msg += "for more info".white
      return error msg

    # otherwise if file exists, go ahead and read it's contents
    contents = fs.readFileSync filepath, "utf-8"

    # watch the config file, and reloads polvo everytime it changes
    if @polvo.cli.argv.w
      
      watcher = fsu.watch filepath
      watcher.on 'change', (f)=>
        now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]
        filepath = filepath.replace @polvo.basepath, ''
        log "[#{now}] #{'Changed'.bold} #{filepath}".cyan
        log "~> Reloading Polvo.".bold
        watcher.close()
        @polvo.reset()

    # now tries to compile it down to js
    try
      code = cs.compile contents, {bare:1}
    # and if some error ocurrs, shows it and aborts
    catch err
      error "Error compiling `polvo.coffee` config file\n\n#{err}"
      return proces.exit()

    # if no errors, fix the `toast` call scope
    fix_scope = /(^[\s\t]?)(setup)+(\()/mg
    code = code.replace fix_scope, "$1this.$2$3"

    # and finally execute it
    eval code



  setup:( config )=>

    return unless @validate_server config
    return unless @validate_sources config
    return unless @validate_excludes config
    return unless @validate_includes config
    return unless @validate_destination config

    @confs.push config



  validate_server:( config )->
    return yes unless config.browser?

    unless config.server.root?
      msg = 'You need to inform the `root` property in your server config.'
      msg += '\nCheck your config file.'
      return error msg

    server.port ?= 3000

    return yes

  validate_sources:( config )->
    if config.sources is null or config.sources.length is 0
      msg = 'You need to inform at least one source, check your config file.'
      return error msg

    # expand and validates and all dir paths
    for src, index in config.sources

      # expanding absolute path
      if src.indexOf( @basepath ) < 0
        src = path.join @basepath, src

      # if folder exists
      if fs.existsSync src
        config.sources[index] = src

      # otherwise if folder is not found
      else
        msg = "Informed source doesn't exist:\n\t#{src.yellow}"
        msg += '\nCheck your config file.'
        return error msg

    return yes

  validate_destination:( config )->
    if config.destination is null
      msg = 'You need to inform a destination folder, check your config file.'
      return error msg

    # expanding absolute path
    if config.destination.indexOf( @basepath ) < 0
      config.destination = path.join @basepath, config.destination

    # if folder exists
    unless fs.existsSync config.destination
      fsu.mkdir_p config.destination
      msg = "Config `output_dir` doesn't exist, creating one:"
      msg += "\n\t#{config.destination.cyan}"
      warn msg

    return yes

  validate_excludes:( config )->
    config.exclude ?= []
    return yes

  validate_includes:( config )->
    config.include ?= []
    return yes