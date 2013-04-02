require('source-map-support').install()

fsu = require 'fs-util'

module.exports = class Tree

  handler: null
  optimizer: null

  files: []
  watchers = null

  constructor:( @toaster, @config, @handler, @optimizer )->
    # console.log 'tree'
    # console.log @config
    # console.log @handler?
    # console.log @optimizer?
    # return
    @init()

  # collects all files covered by internal handler
  init:->
    @files = []

    # loops through all dirs and..
    for dir in @config.dirs

      # collects all files
      for file in (fsu.find dir, @handler.FILTER)

        # check if file should be included or ignored
        include = true
        for item in @config.exclude
          include &= !(new RegExp( item ).test file)

        # if it should be included, add to @files array
        @files.push (new @handler @, dir, file) if include

  # optimize all files covered by internal handler
  optimize:->
    optimizer @files, @config

  watch:()->
    # initialize watchers array
    @watchers = []

    # loops through all dirs
    for dir in @config.dirs

      # and watch them entirely
      @watchers.push (watcher = fsu.watch dir, @    .EXT)
      watcher.on 'create', (FnUtil.proxy @on_fs_change, false, dir, 'create')
      watcher.on 'change', (FnUtil.proxy @on_fs_change, false, dir, 'change')
      watcher.on 'delete', (FnUtil.proxy @on_fs_change, false, dir, 'delete')

    # watching vendors for changes
    for vname, vpath of @config.vendors
      @watchers.push (watcher = fsu.watch vpath)
      dir = path.join (path.dirname vpath), '..'
      watcher.on 'create', (FnUtil.proxy @on_fs_change, true, dir, 'create')
      watcher.on 'change', (FnUtil.proxy @on_fs_change, true, dir, 'change')
      watcher.on 'delete', (FnUtil.proxy @on_fs_change, true, dir, 'delete')

  close_watchers:->
    watcher.close() for watcher in @watchers

  on_fs_change:(is_vendor, dir, event, file)=>

    # skip all folder creation
    return if file.type is "dir" and event == "create"
    
    # expand file location and type
    {location, type} = file

    # check if it should be be ignored..
    include = true
    for item in @config.exclude
      include &= not (new RegExp( item ).test location)

    # and aborts in case it should!
    return unless include

    # titleize the type for use in the log messages bellow
    type = StringUtil.titleize file.type

    # relative filepath
    relative_path = location.replace dir, ''
    relative_path = (relative_path.substr 1) if relative_path[0] is path.sep

    # date for CLI notifications
    now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

    # switch over created, deleted, updated and watching
    switch event

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