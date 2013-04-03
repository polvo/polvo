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
  confs: []

  constructor: (@toaster) ->
    @basepath = @toaster.basepath
    @confs = []

    @init()

  init:->
    # if config is json
    if (config = @toaster.cli.argv["config"])?
      config = JSON.parse( config ) unless config instanceof Object
      @toast item for item in ( [].concat config )
      return

    # otherwise if it's file, evaluates it's path
    config_file = @toaster.cli.argv["config-file"]
    filepath = config_file || path.join @basepath, "toaster.coffee"

    # if file doesn't exist
    unless fs.existsSync filepath

      # rise and error and aborts
      msg = "Config file not found: #{filepath.yellow}\n"
      msg += "Try running:".white + " toaster -i".green
      msg += " or type".white + " #toaster -h'".green
      msg += "for more info".white
      return error msg

    # otherwise if file exists, go ahead and read it's contents
    contents = fs.readFileSync filepath, "utf-8"

    # watch the config file, and reloads toaster everytime it changes
    if @toaster.cli.argv.w
      
      watcher = fsu.watch filepath
      watcher.on 'change', (f)=>
        now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]
        filepath = filepath.replace @toaster.basepath, ''
        log "[#{now}] #{'Changed'.bold} #{filepath}".cyan
        log "~> Reloading Toaster.".bold
        watcher.close()
        @toaster.reset()

    # now tries to compile it down to js
    try
      code = cs.compile contents, {bare:1}
    # and if some error ocurrs, shows it and aborts
    catch err
      error "Error compiling `toaster.coffee` config file\n\n#{err}"
      return proces.exit()

    # if no errors, fix the `toast` call scope
    fix_scope = /(^[\s\t]?)(toast)+(\()/mg
    code = code.replace fix_scope, "$1this.$2$3"

    # and finally execute it
    eval code



  toast:( config )=>

    return unless @validate_languages config
    return unless @validate_server config

    if config.languages.javascript is 'coffeescript'
      new CoffeeConfig config, @basepath

    # if languages.stylus?
    #   new StylusConfig config.stylus
    #  etc...

    @confs.push config


  validate_languages:( config )->
    unless config.languages?
      msg = "Property `languages` not specified in config: #{filepath.yellow}\n"
      return error msg
    return yes

  validate_server:( config )->
    return yes unless config.browser?

    unless config.server.root?
      msg = 'You need to inform the `root` property in your server config.'
      msg += '\nCheck your config file.'
      return error msg

    server.port ?= 3000

    return yes