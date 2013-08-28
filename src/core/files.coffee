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
  watchers_foreing: null
  foreing_caller: false

  constructor:->
    @collect()

  collect:->
    @watchers = []
    @watchers_foreing = {}
    @files = []
    for dirpath in config.input
      for filepath in fsu.find dirpath, exts
        @create_file filepath

    @watch_inputs() if argv.watch

  restart:( file )->
    @close_watchers()
    @collect()

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

    is_under_inputs = true
    for dirpath in config.input
      is_under_inputs and= (filepath.indexOf(dirpath) is 0)
    
    if not is_under_inputs
      @watch_file file.filepath if argv.watch

    if @foreign_caller
      log_created file.filepath
      @compile @foreign_caller

    file

  delete_file:(filepath)->        
    file = _.find @files, {filepath}
    @restart file
    return file

  bulk_create_file:(deps)=>
    @create_file dep for dep in deps

  refresh_dependents:( dependents )=>
    for dependent in dependents
      file = _.find @files, {filepath:dependent.filepath}
      file.refresh() if file?

  watch_file:( filepath )->
    dir = path.dirname filepath
    unless @watchers_foreing[dir]?
      @watchers_foreing[dir] = true
      @watchers.push watcher = fsu.watch dir
      watcher.on 'create', (file)=> @onfschange 'create', file, true
      watcher.on 'change', (file)=> @onfschange 'change', file, true
      watcher.on 'delete', (file)=> @onfschange 'delete', file, true

  watch_inputs:->
    for dirpath in config.input
      @watchers.push watcher = fsu.watch dirpath, exts
      watcher.on 'create', (file)=> @onfschange 'create', file
      watcher.on 'change', (file)=> @onfschange 'change', file
      watcher.on 'delete', (file)=> @onfschange 'delete', file

  close_watchers:( preserve_outsiders )->
    for watcher in @watchers
      if preserve_outsiders?
        continue if watcher.root in @watchers_foreing
        watcher.close()

  onfschange:(action, file, foreign)=>

    {location, type} = file

    return if type == "dir" and action == "create"

    switch action

      when "create"
        if foreign
          for file in @files
            @foreign_caller = file
            file.scan_deps()

          @foreign_caller = null
          return

        file = @create_file location
        log_created location
        @compile file

      when "delete"
        file = @delete_file location
        if file
          log_deleted location
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