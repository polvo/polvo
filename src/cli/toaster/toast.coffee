Builder = require './core/builder'

{log,debug,warn,error} = require './utils/log-util'

module.exports = class Toast

  # requires
  fs = require "fs"
  fsu = require "fs-util"
  path = require "path"
  exec = (require "child_process").exec
  colors = require 'colors'
  cs = require "coffee-script"

  # variables
  builders: null

  constructor: (@toaster) ->

    # basepath
    @basepath = @toaster.basepath
    @builders = []

    # if config is json
    if (config = @toaster.cli.argv["config"])?
      config = JSON.parse( config ) unless config instanceof Object
      @toast item for item in ( [].concat config )

    # otherwise if it's file
    else

      # evaluates it's path
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


  toast:( config = {} )=>

    # normalize and validate all options in `toaster.coffee`

    # ...: exclude - optional
    config.exclude ?= []

    # ...: bare - optional
    config.bare ?= true # boolean

    # ...: minify - optional
    config.minify ?= true # boolean

    # ...: webroot - optional
    config.webroot ?= '' # string
    if @toaster.cli.argv.s? and config.webroot is ''
      msg = 'Informe your webroot for using static server.'
      msg += '\nCheck your `toaster.coffee` config file.'
      return error msg

    # ...: port - optional
    config.port ?= 3000

    # ...: main - mandatory
    unless config.main?
      msg = 'You need to inform the main entry point (module id) for your app.'
      msg += '\nCheck your `toaster.coffee` config file.'
      return error msg

    # ...: dirs - mandatory
    if config.dirs is null or config.dirs.length is 0
      msg = 'You need to inform at least one dir or source files.'
      msg += '\nCheck your `toaster.coffee` config file.'
      return error msg

    for dir, i in config.dirs
      dir = path.join @basepath, dir
      if fs.existsSync dir
        config.dirs[i] = dir
      else
        msg = 'Informed dir doesn\'t exist:\n\t#{dir.yellow}'
        msg += '\nCheck your `toaster.coffee` config file.'
        return error msg

    # ...: release_dir - mandatory
    if config.release_dir is null
      msg = 'You need to inform your `release_dir`'
      msg += '\nCheck your `toaster.coffee` config file.'
      return error msg
    else
      config.release_dir = path.join @basepath, config.release_dir
      unless fs.existsSync (path.dirname config.release_dir)
        msg = "`release_dir` doesn't exist:\n\t#{config.release_dir.yellow}"
        msg += '\nCheck your `toaster.coffee` config file.'
        return error msg

    # ...:optimize - optional
    if config.optimize?

      # ...: base_url - optional
      if config.optimize.base_url?
        if config.optimize.base_url.slice -1 isnt '/'
          config.optimize.base_url += '/'
      else
         config.optimize.base_url = ''

      # ...: vendors - optional
      if config.optimize.vendors?
        for vname, vurl of config.optimize.vendors

          continue if /^http/m.test vurl

          vpath = path.join @basepath, vurl

          if fs.existsSync vpath
            if (fs.lstatSync vpath).isSymbolicLink()
              vpath = fs.readlinkSync vendor
            config.optimize.vendors[vname] = vpath

          else
            # error "Local vendor not found. #{dir}\nCheck your config."
            msg = 'Check your `toaster.coffee` config file, local vendor was '
            msg += 'not found:\n\t' + vpath
            return error msg
            
    builder = new Builder @toaster, @toaster.cli, config
    @builders.push builder