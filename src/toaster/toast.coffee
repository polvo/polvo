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
        error "File not found: ".yellow + " #{filepath.red}\n" +
          "Try running:".yellow + " toaster -i".green +
          " or type".yellow + " #toaster -h'".green +
          "for more info".yellow

        return null

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

    # ...: dirs - mandatory
    if config.dirs is null or config.dirs.length is 0
      msg = 'Check your `toaster.coffee` config file, you need to inform at'
      msg += 'least one dir in your config file.'
      return error msg

    for dir, i in config.dirs
      dir = path.join @basepath, dir
      if fs.existsSync dir
        config.dirs[i] = dir
      else
        msg = 'Check your `toaster.coffee` config file, informed dir doens\'t '
        msg += 'exist:\n\tleast one dir in your config file.'
        return error msg

    # ...: release_dir - mandatory
    if config.release_dir is null
      msg = 'Check your `toaster.coffee` config file, `release_dir` must to'
      msg += 'be informed.'
      return error msg
    else
      config.release_dir = path.join @basepath, config.release_dir
      unless fs.existsSync (path.dirname config.release_dir)
        error "Release dir doesn't exist:\n\t#{dir.yellow}"
        return null

    # ...:optimize - optional
    if config.optimize?

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