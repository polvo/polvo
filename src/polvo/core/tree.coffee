path = require 'path'
fs = require 'fs'
util = require 'util'
fsu = require 'fs-util'

FnUtil = require '../utils/fn-util'
StringUtil = require '../utils/string-util'
ArrayUtil = require '../utils/array-util'

File = require './file'

{log,debug,warn,error} = require '../utils/log-util'

module.exports = class Tree

  files: []

  watchers = null
  optimizer: null

  constructor:( @polvo, @cli, @config, @tentacle )->
    do @init

  # collects all files covered by internal Handler
  init:->
    @files = []
    for src in @config.sources
      for filepath in (fsu.find src, File.EXTENSIONS)
        @files.push new File @polvo, @cli, @config, @tentacle, @, src, filepath

        # HANDLE INCLUDE AND EXCLUDES >>>>>>>>>>>>>
        # # check if file should be included or ignored
        # include = true
        # for pattern in @config.exclude
        #   include &= !(pattern.test filepath)

        # # if it should be included, add to @files array
        # continue unless include
        # <<<<<<<<<<<< HANDLE INCLUDE AND EXCLUDES

  

  # optimize all files covered by internal Handler
  optimize:->
    do @optimizer.optimize

  compile_files_to_disk:->
    for file in @files
      do file.compile_to_disk

  watch:()->
    # initialize watchers array
    @watchers = []

    # loops through all dirs
    for src in @config.sources

      # and watch them entirely
      @watchers.push (watcher = fsu.watch src, File.EXTENSIONS)
      watcher.on 'create', (FnUtil.proxy @_on_fs_change, false, src, 'create')
      watcher.on 'change', (FnUtil.proxy @_on_fs_change, false, src, 'change')
      watcher.on 'delete', (FnUtil.proxy @_on_fs_change, false, src, 'delete')

    # watching vendors for changes
    for vname, vpath of @config.vendors.javascript
      continue if vname is 'incompatible'
      @watchers.push (watcher = fsu.watch vpath)
      src = path.join (path.dirname vpath), '..'
      
      watcher.on 'create', (FnUtil.proxy @_on_fs_change, true, src, 'create')
      watcher.on 'change', (FnUtil.proxy @_on_fs_change, true, src, 'change')
      watcher.on 'delete', (FnUtil.proxy @_on_fs_change, true, src, 'delete')

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

    # switch over created, deleted, updated and watching
    switch ev

      # when a new file is created
      when "create"

        # cli filepath
        msg = "+ #{type} created".bold
        log "#{msg} #{relative_path}".cyan

        # initiate file and adds it to the array
        file = new File @polvo, @cli, @config, @tentacle, @, dir, location
        @files.push file
        do file.compile_to_disk

      # when a file is deleted
      when "delete"

        # removes files from array
        file = ArrayUtil.find @files, {relative_path}
        return if file is null

        do file.item.delete_from_disk
        @files.splice file.index, 1

        # cli msg
        msg = "- #{type} deleted".bold
        log "#{msg} #{relative_path}".red

      # when a file is updated
      when "change"
        # updates file information
        file = ArrayUtil.find @files, {relative_path}

        if file is null and is_vendor is false
          warn "Change file is apparently null, it shouldn't happened.\n"+
              "Please report this at the repo issues section."
        else

          # cli msg
          msg = "• #{type} changed".bold
          log "#{msg} #{relative_path}".cyan

          if is_vendor
            @tentacle.optimizer.copy_vendors_to_release false, location
          else
            do file.item.refresh
            file.item.compile_to_disk true