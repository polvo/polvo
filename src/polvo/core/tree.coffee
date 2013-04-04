require('source-map-support').install()

path = require 'path'
fs = require 'fs'
util = require 'util'
fsu = require 'fs-util'

FnUtil = require '../utils/fn-util'
StringUtil = require '../utils/string-util'
ArrayUtil = require '../utils/array-util'

{log,debug,warn,error} = require '../utils/log-util'

module.exports = class Tree

  files: []
  filter: null
  watchers = null
  optimizer: null

  constructor:( @polvo, @cli, @config, @toast, HandlerClass, OptimizerClass )->

    @filter = HandlerClass.FILTER
    @init HandlerClass, OptimizerClass

  # collects all files covered by internal Handler
  init:( HandlerClass, OptimizerClass )->
    @files = []

    @optimizer = new OptimizerClass @polvo, @cli, @config, @

    # loops through all dirs and..
    for dirpath in @config.dirs

      # collects all files
      for filepath in (fsu.find dirpath, @filter)

        # check if file should be included or ignored
        include = true
        for item in @config.exclude
          include &= !(new RegExp( item ).test filepath)

        # if it should be included, add to @files array
        continue unless include

        handler = new HandlerClass @polvo,
                                @cli,
                                @config,
                                @,
                                dirpath,
                                filepath
        @files.push handler

  clear_output_dir:->
    # clear release folder
    fsu.rm_rf @config.output_dir if fs.existsSync @config.output_dir
    fsu.mkdir_p @config.output_dir

  # optimize all files covered by internal Handler
  optimize:->
    do @clear_output_dir
    do @optimizer.optimize

  compile_files_to_disk:->
    do @clear_output_dir

    for file in @files
      file.compile_to_disk @config

    @optimizer.optimize_for_development?()

  watch:()->
    # initialize watchers array
    @watchers = []

    # loops through all dirs
    for dir in @config.dirs

      # and watch them entirely
      @watchers.push (watcher = fsu.watch dir, @filter)
      watcher.on 'create', (FnUtil.proxy @_on_fs_change, false, dir, 'create')
      watcher.on 'change', (FnUtil.proxy @_on_fs_change, false, dir, 'change')
      watcher.on 'delete', (FnUtil.proxy @_on_fs_change, false, dir, 'delete')

    # watching vendors for changes
    for vname, vpath of @config.vendors
      @watchers.push (watcher = fsu.watch vpath)
      dir = path.join (path.dirname vpath), '..'
      watcher.on 'create', (FnUtil.proxy @_on_fs_change, true, dir, 'create')
      watcher.on 'change', (FnUtil.proxy @_on_fs_change, true, dir, 'change')
      watcher.on 'delete', (FnUtil.proxy @_on_fs_change, true, dir, 'delete')

  close_watchers:->
    for watcher in @watchers
      watcher.close()

  _on_fs_change:(is_vendor, dir, ev, f)=>

    # skip all folder creation
    return if f.type == "dir" and ev == "create"
    
    # expand file location and type
    {location, type} = f

    # check if it should be be ignored..
    include = true
    include &= !(new RegExp( item ).test location) for item in @config.exclude

    # and aborts in case it should!
    return unless include

    # titleize the type for use in the log messages bellow
    type = StringUtil.titleize f.type

    # relative filepath
    relative_path = location.replace dir, ''
    relative_path = (relative_path.substr 1) if relative_path[0] is path.sep


    # date for CLI notifications
    now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

    # switch over created, deleted, updated and watching
    switch ev

      # when a new file is created
      when "create"

        # cli filepath
        msg = "+ #{type} created".bold
        log "[#{now}] #{msg} #{relative_path}".cyan

        # initiate file and adds it to the array
        @files.push script = new Script @, dir, location
        script.compile_to_disk @config

      # when a file is deleted
      when "delete"

        # removes files from array
        file = ArrayUtil.find @files, 'filepath': relative_path
        return if file is null

        file.item.delete_from_disk()
        @files.splice file.index, 1

        # cli msg
        msg = "- #{type} deleted".bold
        log "[#{now}] #{msg} #{relative_path}".red

      # when a file is updated
      when "change"

        # updates file information
        file = ArrayUtil.find @files, 'filepath': relative_path

        if file is null and is_vendor is false
          warn "Change file is apparently null, it shouldn't happened.\n"+
              "Please report this at the repo issues section."
        else

          # cli msg
          msg = "• #{type} changed".bold
          log "[#{now}] #{msg} #{relative_path}"

          if is_vendor
            @copy_vendors_to_release false, location
          else
            file.item.getinfo()
            file.item.compile_to_disk @config