Builder = require './core/builder'

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

    if (config = @toaster.cli.argv["config"])?
      config = JSON.parse( config ) unless config instanceof Object
      @toast item for item in ( [].concat config )
    else
      config_file = @toaster.cli.argv["config-file"]
      filepath = config_file || path.join @basepath, "toaster.coffee"

      if @toaster.cli.argv.w
        watcher = fsu.watch filepath
        watcher.on 'change', (f)=>
          now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]
          log "[#{now}] #{'Changed'.bold} #{filepath}".cyan
          watcher.close()
          @toaster.reset()

      if fs.existsSync filepath

        contents = fs.readFileSync filepath, "utf-8"
        
        try
          code = cs.compile contents, {bare:1}
        catch err
          error err.message + " at 'toaster.coffee' config file."

        fix_scope = /(^[\s\t]?)(toast)+(\()/mg
        code = code.replace fix_scope, "$1this.$2$3"
        eval code
      else
        error "File not found: ".yellow + " #{filepath.red}\n" +
          "Try running:".yellow + " toaster -i".green +
          " or type".yellow + " #{'toaster -h'.green} " +
          "for more info".yellow

  
  toast:( srcpath, params = {} )=>

    
    if srcpath instanceof Object
      params = srcpath
    else if path.resolve srcpath != srcpath
      folder = path.join @basepath, srcpath


    if params.nature.browser?
      params.nature.browser.minify ?= true

      if params.nature.browser.release is null
        error 'Release path not informed in config.'
        return process.exit()
      else
        dir = path.dirname params.nature.browser.release
        unless fs.existsSync (path.join @basepath, dir)
          error "Release folder does not exist:\n\t#{dir.yellow}"
          return process.exit()

    # configuration object shared between builders
    if params.debug
      debug = path.join @basepath, params.debug
    else
      debug = null

    config =
        # src folders
        src_folders: []

        # options
        nature: params.nature
        exclude: params.exclude ? []
        bare: params.bare ? true
        release: path.join @basepath, params.release


    # # compute vendors full path
    # for v, i in config.vendors
    #   vpath = config.vendors[i] = (path.resolve v)
    #   if (path.resolve vpath) isnt vpath
    #     config.vendors[i] = path.join @basepath, v

    unless srcpath instanceof Object
      srcpath = path.resolve( path.join @basepath, srcpath )
      config.src_folders.push
        path: srcpath
        alias: params.alias || null

    if params.folders?
      for folder, alias of params.folders
        if (path.resolve folder) != folder
          folder = path.join @basepath, folder
        config.src_folders.push {path: folder, alias: alias}

    for item in config.src_folders
      unless fs.existsSync item.path
        console.error "Source folder doens't exist:\n\t#{item.path.red}\n" + 
            "Check your #{'toaster.coffee'.yellow} and try again." +
            "\n\t" + (path.join @basepath, "toaster.coffee" ).yellow
        return process.exit()

    builder = new Builder @toaster, @toaster.cli, config
    @builders.push builder
