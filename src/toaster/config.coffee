require('source-map-support').install()

# requires
fs = require "fs"
fsu = require "fs-util"
path = require "path"

colors = require 'colors'
cs = require "coffee-script"

{log,debug,warn,error} = require './utils/log-util'

module.exports = class Config

  # variables
  confs: null

  constructor: (@toaster) ->

    # basepath
    @basepath = @toaster.basepath
    @confs = []

    # if config is json
    if (config = @toaster.cli.argv["config"])?
      config = JSON.parse( config ) unless config instanceof Object
      @toast item for item in ( [].concat config )

    # otherwise if it's file
    else

      # evaluates it's path
      config_file = @toaster.cli.argv["config-file"]
      filepath = config_file || path.join @basepath, "toaster.coffee"

      if @toaster.cli.argv.w
        # watch it for changes, and automatically reloads itself
        watcher = fsu.watch filepath
        watcher.on 'change', (f)=>
          now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]
          filepath = filepath.replace @toaster.basepath, ''
          log "[#{now}] #{'Changed'.bold} #{filepath}".cyan
          log "~> Reloading Toaster.".bold
          watcher.close()
          @toaster.reset()

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


  # normalize and validate all options in `toaster.coffee`
  toast:( config = {} )=>

    # ...: release_dir - mandatory
    if config.release_dir is null
      msg = 'You need to inform your `release_dir`'
      msg += '\nCheck your `toaster.coffee` config file.'
      return error msg
    else
      if config.release_dir.indexOf( @basepath ) < 0
        config.release_dir = path.join @basepath, config.release_dir
      unless fs.existsSync (path.dirname config.release_dir)
        msg = "`release_dir` doesn't exist:\n\t#{config.release_dir.yellow}"
        msg += '\nCheck your `toaster.coffee` config file.'
        return error msg

    # ...: exclude - optional
    config.exclude ?= []

    # ...: bare - optional
    config.bare ?= true

    # ...: dirs - mandatory
    if config.dirs is null or config.dirs.length is 0
      msg = 'You need to inform at least one dir or source files.'
      msg += '\nCheck your `toaster.coffee` config file.'
      return error msg

    # validates and increments all dir's paths
    for dir, i in config.dirs
      if dir.indexOf( @basepath ) < 0
        dir = path.join @basepath, dir

      if fs.existsSync dir
        config.dirs[i] = dir
      else
        msg = "Informed dir doesn't exist:\n\t#{dir.yellow}"
        msg += '\nCheck your `toaster.coffee` config file.'
        return error msg

    # project nature
    if config.browser?
      @_toast_browser config
    else
      # TODO
      # @_toast_node config.node or {}

  _toast_browser:( config )->

    browser = config.browser

    # ...: amd - optional
    if browser.amd?

      # ...: main - mandatory
      unless browser.amd.main?
        msg = 'You need to inform the main entry point (module id) for your '
        msg += 'app. \nCheck your `toaster.coffee` config file.'
        return error msg

      # ...: boot - mandatory
      unless browser.amd.boot?
        msg = 'You need to inform the amd/boot file name for your app.'
        msg += '\nCheck your `toaster.coffee` config file.'
        return error msg

      # ...: base_url - optional
      if browser.amd.base_url?
        if browser.amd.base_url.slice -1 isnt '/'
          browser.amd.base_url += '/'
      else
          browser.amd.base_url = ''

    # ...: server - optional
    if server?

      # ...: root  (mandatory when server is informed)
      unless server.root?
        msg = 'You need to inform the `root` property in your server config.'
        msg += '\nCheck your `toaster.coffee` config file.'
        return error msg

      # ...: port - optional
      server.port ?= 3000

    # ...: vendors - optional
    if browser.vendors?
      for vname, vurl of browser.vendors

        continue if /^http/m.test vurl

        if vurl.indexOf( @basepath ) < 0
          vpath = path.join @basepath, vurl

        if fs.existsSync vpath
          if (fs.lstatSync vpath).isSymbolicLink()
            vurl = path.resolve (fs.readlinkSync vurl)

          browser.vendors[vname] = vpath

        else
          # error "Local vendor not found. #{dir}\nCheck your config."
          msg = 'Check your `toaster.coffee` config file, local vendor was '
          msg += 'not found:\n\t' + vpath
          return error msg

    # ...:optimize - optional
    browser.optimize ?= null

    # ...:optimization method (at least one should be specified)
    if browser.optimize?

      # ...: minify - optional
      browser.minify ?= true # boolean

      if (browser.optimize.merge? or browser.optimize.layers?) is false
        msg = 'Check your `toaster.coffee` at least one method is need in order'
        msg += ' to optimize your project.'
        return error msg

      else if (browser.optimize.merge? and browser.optimize.layers?)
        msg = 'Check your `toaster.coffee`, only one optimization method is '
        msg += 'allowed, please use `layers` or `merge`.'
        return error msg        

    @confs.push config