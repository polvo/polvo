# requires
fs = require "fs"
fsu = require "fs-util"
path = require "path"

colors = require 'colors'
cs = require "coffee-script"

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
        filepath = filepath.replace @polvo.basepath, ''
        log "#{'Changed'.bold} #{filepath}".cyan
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

    passed = true
    passed and= a = @validate_server config
    passed and= b = @validate_sources config
    passed and= c = @validate_excludes config
    passed and= d = @validate_includes config
    passed and= e = @validate_destination config
    passed and= f = @validate_wrappers config
    passed and= g = @validate_vendors config

    unless passed
      process.exit()
    else
      @confs.push config


  validate_server:( config )->
    return yes if config is null

    unless config?.server?.root?
      msg = 'You need to inform the `root` property in your server config.'
      msg += '\nCheck your config file.'
      return error msg

    config.server.root = path.resolve config.server.root
    config.server.port ?= 3000

    return yes

  validate_sources:( config )->
    unless config.sources? and config.sources.length
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
    unless config.destination?
      msg = 'You need to inform a destination folder, check your config file.'
      return error msg

    # expanding absolute path
    if config.destination.indexOf( @basepath ) < 0
      config.destination = path.join @basepath, config.destination

    # if folder exists
    unless fs.existsSync config.destination
      fsu.mkdir_p config.destination
      msg = "Creating `destination` dir: #{config.destination.cyan}"
      warn msg

    return yes

  validate_excludes:( config )->
    config.exclude ?= []
    return yes

  validate_includes:( config )->
    config.include ?= []
    return yes


  validate_wrappers:( config )->
    unless config.wrappers?
      config.wrappers = javascript: 'amd', style: 'amd'
    else
      config.wrappers.javascript ?= 'amd'
      config.wrappers.style ?= 'amd'

    return yes

   # vendors (optional)
  validate_vendors:( config )->
    for vname, vpath of config?.vendors?.javascript
      # skip cdn vendors or incompatible vendors
      if (/^http/m.test vpath) or (vname is 'incompatible')
        continue

      # expands absolute path as needed
      if (vpath.indexOf @basepath) < 0
        vpath = path.join @basepath, vpath

      # if file is a symbolic link, expands it's realpath
      # if (fs.lstatSync vpath).isSymbolicLink()
      #   vpath = path.join (path.dirname vpath), (fs.readlinkSync vpath)

      # check file existence
      unless fs.existsSync vpath
        # error "Local vendor not found. #{dir}\nCheck your config."
        msg = 'Local vendor not found:'
        msg += '\n\t' + vpath
        msg += '\nCheck your config file.'
        return error msg

      config.vendors.javascript[vname] = vpath
    
    return yes