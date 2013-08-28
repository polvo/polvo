path = require 'path'
fsu = require 'fs-util'
_ = require 'lodash'

dirs = require '../utils/dirs'
config = require('../utils/config').parse()
compiler = require './compiler'

cli = require '../cli'
plugins = require '../utils/plugins'
logger = require('../utils/logger')('core/files')

{error, warn, info, debug} = logger

log_created = logger.file.created
log_changed = logger.file.changed
log_deleted = logger.file.deleted

File = require './file'

module.exports = new class Files

  argv = cli.argv()
  exts = (plugin.ext for plugin in plugins)

  files: null
  watchers: null

  constructor:->
    @watchers = []
    @collect()

  collect:->
    @files = []
    for dirpath in config.input
      for filepath in fsu.find dirpath, exts
        @create_file filepath

    @watch_inputs() if argv.watch

  has_compiler:(filepath)->
    (return yes if ext.test filepath) for ext in exts
    return no

  create_file:(filepath)->
    return if not @has_compiler filepath
    return file if file = _.find @files, {filepath}

    @files.push file = new File filepath
    file.on 'new:dependencies', @bulk_create_file
    file.on 'refresh:dependents', @refresh_dependents
    file.init()
    
    if argv.watch and not @is_under_inputs filepath
      @watch_file file.filepath

    file

  extract_file:(filepath)->
    index = _.findIndex @files, (f)-> f.filepath is filepath
    @files.splice(index, 1)[0]

  is_under_inputs:( filepath, consider_virtuals )->
    input = true
    for dirpath in config.input
      input and= filepath.indexOf(dirpath) is 0

    if consider_virtuals
      virtual = true
      for map, dirpath of config.virtual
        dirpath = path.join dirs.pwd(), dirpath
        virtual and= filepath.indexOf(dirpath) is 0

    input or virtual

  bulk_create_file:(deps)=>
    @create_file dep for dep in deps

  refresh_dependents:( dependents )=>
    for dependent in dependents
      file = _.find @files, {filepath:dependent.filepath}
      file.refresh() if file?

  watch_file:( filepath )->
    dir = path.dirname filepath
    watched = _.find @watchers, root: dir

    unless watched?
      @watchers.push watcher = fsu.watch dir
      watcher.on 'create', (file)=> @onfschange 'create', file
      watcher.on 'change', (file)=> @onfschange 'change', file
      watcher.on 'delete', (file)=> @onfschange 'delete', file

  watch_inputs:->
    for dirpath in config.input
      watched = _.find @watchers, root: dirpath

      unless watched?
        @watchers.push watcher = fsu.watch dirpath, exts
        watcher.on 'create', (file)=> @onfschange 'create', file
        watcher.on 'change', (file)=> @onfschange 'change', file
        watcher.on 'delete', (file)=> @onfschange 'delete', file

  close_watchers:->
    watcher.close() for watcher in @watchers

  onfschange:(action, file)=>

    {location, type} = file

    return if type == "dir" and action == "create"
    return if type == "dir" and action == "delete"

    switch action

      when "create"
        file = @create_file location
        log_created location
        @compile file

      when "delete"

        console.log 'delete', location
        log_deleted location
        file = @extract_file location

        # check if others have the same dependencies
        for depname, depath of file.dependencies
          found = 0
          for f in @files
            for dname, dpath of f.depenencies
              found++ if dpath is depath

          if not found and not @is_under_inputs(depath, true)
            @extract_file depath unless found

        # search for those who was depending on deleted item
        for f in @files
          for dname, dpath of f.dependencies
            if dpath is file.filepath
                f.scan_deps()

        @compile file

      when "change"
        file = _.find @files, filepath: location

        if file is null
          msg = "Change file is apparently null, it shouldn't happened.\n"
          msg += "Please report this at the repo issues section."
          warn msg
        else
          log_changed location

        file.refresh()
        @compile file

  compile:(file)->
    switch file.output
      when 'js' then compiler.build_js true
      when 'css' then compiler.build_css true