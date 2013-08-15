path = require 'path'
fsu = require 'fs-util'
_ = require 'lodash'

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
    @files = []
    for dirpath in config.input
      for filepath in fsu.find dirpath, exts
        @new_file filepath

    @watch() if argv.watch

  has_compiler:(filepath)->
    (return yes if ext.test filepath) for ext in exts
    return no

  new_file:(filepath)->
    return if not @has_compiler filepath
    return if _.find @files, {filepath}

    file = new File filepath
    file.on 'deps', @new_deps
    file.init()
    @files.push file

  new_deps:(deps)=>
    @new_file dep for dep in deps

  watch:->
    watchers = []

    for dirpath in config.input
      watchers.push (watcher = fsu.watch dirpath, exts)
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
        @new_file filepath
        msg = "+ #{type} created".bold
        console.log "#{msg} #{location}".cyan        
        compiler.build()

      when "delete"
        file = _.find @files, filepath: location
        index = _.indexOf @files, filepath: location

        if file?
          @files.splice index, 1
          msg = "- #{type} deleted".bold
          compiler.build()
          console.log "#{msg} #{location}".red


      when "change"
        file = _.find @files, filepath: location

        if file is null and vendor is false
          msg = "Change file is apparently null, it shouldn't happened.\n"
          msg += "Please report this at the repo issues section."
          console.warn msg
        else
          msg = "• #{type} changed".bold
          console.log "#{msg} #{location}".cyan

        file.refresh() if not vendor
        compiler.build()