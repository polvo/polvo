require('source-map-support').install()

path = require 'path'
fs = require 'fs'
util = require 'util'
fsu = require 'fs-util'

FnUtil = require '../utils/fn-util'
{log,debug,warn,error} = require '../utils/log-util'

module.exports = class Tree

  files: []
  filter: null
  watchers = null
  optimizer: null

  constructor:( @toaster, @cli, @config, @toast, HandlerClass, OptimizerClass )->
    @filter = HandlerClass.FILTER
    @init HandlerClass, OptimizerClass

  # collects all files covered by internal Handler
  init:( HandlerClass, OptimizerClass )->
    @files = []

    @optimizer = new OptimizerClass @toaster, @cli, @config, @

    # loops through all dirs and..
    for dirpath in @config.dirs

      # collects all files
      for filepath in (fsu.find dirpath, HandlerClass.FILTER)

        # check if file should be included or ignored
        include = true
        for item in @config.exclude
          include &= !(new RegExp( item ).test filepath)

        # if it should be included, add to @files array
        continue unless include

        handler = new HandlerClass @toaster,
                                @cli,
                                @config,
                                @,
                                dirpath,
                                filepath
        @files.push handler

  clear_release_dir:->
    # clear release folder
    fsu.rm_rf @config.release_dir
    fsu.mkdir_p @config.release_dir

  # optimize all files covered by internal Handler
  optimize:->
    do @clear_release_dir
    do @optimizer.optimize

  compile_files_to_disk:->
    do @clear_release_dir

    for file in @files
      file.compile_to_disk @config

    do @optimizer.optimize_for_development

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
