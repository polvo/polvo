path = require 'path'
fs = require 'fs'
fsu = require 'fs-util'
_ = require 'lodash'

dirs = require '../utils/dirs'
config = require '../utils/config'
compiler = require './compiler'

{argv} = require '../cli'
plugins = require '../utils/plugins'
logger = require('../utils/logger')('core/files')
components = require '../extras/component'

{error, warn, info, debug} = logger

log_created = logger.file.created
log_changed = logger.file.changed
log_deleted = logger.file.deleted

File = require './file'

module.exports = new class Files

  exts = (plugin.ext for plugin in plugins)

  files: null
  watchers: null

  constructor:->
    @watchers = []
    @collect()

  collect:->
    @files = []

    # collecting files from disk
    for dirpath in config.input
      for filepath in fsu.find dirpath, exts
        @create_file filepath

    # collecting component files
    for filepath in components
      @create_file filepath

    @watch_inputs() if argv.watch


  create_file:(filepath)->

    # relative paths means file was not found on disk!
    if (filepath isnt path.resolve filepath)
      # TODO: should possibly computates the probably path to file and watch
      # it for changes, so when the file get there it get properly assembled
      return

    # premature abort in case extension is not recognized
    supported = false
    supported or= ext.test filepath for ext in exts
    return unless supported

    if file = _.find @files, {filepath}
      return file

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

  is_under_inputs:( filepath, consider_aliases )->
    input = true
    for dirpath in config.input
      input and= filepath.indexOf(dirpath) is 0

    if consider_aliases
      alias = true
      for map, dirpath of config.alias
        dirpath = path.join dirs.pwd, dirpath
        alias and= filepath.indexOf(dirpath) is 0

    input or alias

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
    null

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

        log_deleted location
        file = @extract_file location

        # check if file's dependencies are used by other files or if them is
        # under a source or mapped folder
        for depname, depath of file.dependencies

          # if it is under input folders, skip and continue
          continue if @is_under_inputs depath, true

          # otherwise check other files tha may be using it
          found = 0
          for f in @files
            for dname, dpath of f.dependencies
              found++ if dpath is depath

          # if none is found, remove file from build
          if not found
            @extract_file depath

        # them refresh dependencies and dependents
        
        # partial may have dependents
        if file.is_partial
          for dep in file.dependents
            _.find(@files, filepath: dep.filepath).refresh()
        
        # non-partials may be a dependency for another files
        else
          for f in @files
            for dname, dpath of f.dependencies
              if dpath is file.filepath
                f.refresh()

        # restart compilation process
        @compile file

      when "change"
        file = _.find @files, filepath: location
        log_changed location

        # THIS PROBLEM HAS BEEN RESOLVED (APPARENTLY) - will be kept here for
        # a little more to confirm.
        # 
        # if file is null
        #   msg = "Change file is apparently null, it shouldn't happened.\n"
        #   msg += "Please report this at the repo issues section."
        #   warn msg
        # else
        #   log_changed location

        file.refresh()
        @compile file

  compile:(file)->
    switch file.output
      when 'js' then compiler.build_js true
      when 'css' then compiler.build_css true