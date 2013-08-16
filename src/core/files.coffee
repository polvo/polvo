path = require 'path'
fsu = require 'fs-util'
_ = require 'lodash'

dirs = require '../utils/dirs'
config = require '../utils/config'
compiler = require './compiler'

plugins = require '../utils/plugins'

File = require './file'
Cli = require '../cli'

module.exports = new class Files

  {argv} = cli = new Cli
  exts = (plugin.ext for plugin in plugins)

  files: null
  watchers: null


  constructor:->
    @collect()

  collect:->
    @files = []
    for dirpath in config.input
      for filepath in fsu.find dirpath, exts
        @create_file filepath

    @watch() if argv.watch

  restart:( file )->
    watcher.close() for watcher in @watchers
    @collect()

  has_compiler:(filepath)->
    (return yes if ext.test filepath) for ext in exts
    return no

  create_file:(filepath)->
    return if not @has_compiler filepath
    return file if file = _.find @files, {filepath}

    file = new File filepath
    file.on 'new:dependencies', @on_new_dependencies
    file.init()
    @files.push file
    file

  delete_file:(filepath)->        
    file = _.find @files, {filepath}
    @restart file
    return file

  on_new_dependencies:(deps)=>
    @create_file dep for dep in deps

  watch:->
    @watchers = []

    for dirpath in config.input
      @watchers.push (watcher = fsu.watch dirpath, exts)
      watcher.on 'create', (file)=> @onfschange no, dirpath, 'create', file
      watcher.on 'change', (file)=> @onfschange no, dirpath, 'change', file
      watcher.on 'delete', (file)=> @onfschange no, dirpath, 'delete', file

  close_watchers:->
    for watcher in @watchers
      watcher.close()

  onfschange:(vendor, dirpath, action, file)=>

    {location, type} = file

    return if type == "dir" and action == "create"

    switch action

      when "create"
        file = @create_file location
        console.log "+ #{dirs.relative location}".green
        @compile file

      when "delete"
        file = @delete_file location
        if file
          console.log "- #{dirs.relative location}".red
          @compile file

      when "change"
        file = _.find @files, filepath: location

        if file is null and vendor is false
          msg = "Change file is apparently null, it shouldn't happened.\n"
          msg += "Please report this at the repo issues section."
          console.warn msg
        else
          console.log "• #{dirs.relative location}".yellow

        file.refresh() if not vendor
        @compile file

  compile:(file)->
    switch file.output
      when 'js' then compiler.build_js true
      when 'css' then compiler.build_css true