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
  exts = plugin.ext for plugin in plugins

  files: null
  watchers: null


  constructor:->
    @files = []
    for dirpath in config.input
      for filepath in fsu.find dirpath, exts
        @files.push (new File filepath)

    @watch() if argv.watch


  watch:->
    watchers = []

    for dirpath in config.input
      watchers.push (watcher = fsu.watch dirpath, exts)
      watcher.on 'create', (file)=> @onfschange no, dirpath, 'create', file
      watcher.on 'change', (file)=> @onfschange no, dirpath, 'change', file
      watcher.on 'delete', (file)=> @onfschange no, dirpath, 'delete', file

    for name, location of config.vendors.js
      watchers.push (watcher = fsu.watch location)
      watcher.on 'create', (file)=> @onfschange yes, dirpath, 'create', file
      watcher.on 'change', (file)=> @onfschange yes, dirpath, 'change', file
      watcher.on 'delete', (file)=> @onfschange yes, dirpath, 'delete', file


  close_watchers:->
    for watcher in @watchers
      watcher.close()


  onfschange:(vendor, dirpath, action, file)=>

    {location, type} = file

    return if type == "dir" and action == "create"

    # include = true
    # include &= !(new RegExp( item ).test location) for item in @config.exclude
    # return unless include

    # type = StringUtil.titleize f.type

    switch action

      when "create"
        @files.push new File location
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

        # if vendor
        #   @tentacle.optimizer.copy_vendors_to_release false, location
        # else
        file.refresh()
        compiler.build()