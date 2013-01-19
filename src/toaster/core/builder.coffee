FnUtil = require '../utils/fn-util'
ArrayUtil = require '../utils/array-util'
StringUtil = require '../utils/string-util'

Script = require '../core/script'

module.exports = class Builder

  # requirements
  fs = require 'fs'
  fsu = require 'fs-util'
  path = require 'path'
  cs = require "coffee-script"
  cp = require "child_process"

  watchers: null


  constructor:(@toaster, @cli, @config)->

    @bare = @config.bare
    @exclude = [].concat( @config.exclude )

    @nature = @config.nature
    if @config.nature.browser
      @base_url = @nature.browser.base_url
      @minify = @nature.browser.minify
      @release = @config.nature.browser.release
    else
      @minify = false

    @init()
    @watch() if @cli.argv.w


  init:()->
    # initializes buffer array to keep all tracked files
    @files = []

    for folder in @config.src_folders
      # search for all *.coffee files inside src folder
      result = fsu.find folder.path, /.coffee$/m

      # folder path and alias
      fpath = folder.path
      falias = folder.alias

      # collects every files into Script instances
      for file in result

        include = true
        include &= !(new RegExp( item ).test file) for item in @exclude

        @files.push (new Script @, fpath, file, falias, @cli) if include


  reset:()->
    watcher.close() for watcher in @watchers

  build:=>

    # compile all files individually
    @compile()

    # autorun mode
    if @cli.argv.a

      # getting arguments after the third - first three are
      # ['node', 'path_to_toaster', '-a']

      args = []
      if process.argv.length > 3
        for i in [3...process.argv.length] by 1
          args.push process.argv[i]

      if @child?
        log "Application restarted:".blue
        @child.kill('SIGHUP')
      else
        log "Application started:".blue

      # adding debug arguments
      if @cli.argv.d
        @child = cp.fork @release, args, { execArgv: ['--debug-brk'] }
      else
        @child = cp.fork @release, args

  watch:()->

    @watchers = []

    # loops through all source folders
    for src in @config.src_folders

      # and watch them entirely
      @watchers.push (watcher = fsu.watch src.path, /.coffee$/m)
      watcher.on 'create', (FnUtil.proxy @on_fs_change, src, 'create')
      watcher.on 'change', (FnUtil.proxy @on_fs_change, src, 'change')
      watcher.on 'delete', (FnUtil.proxy @on_fs_change, src, 'delete')

    # watching vendors for changes
    # for vendor in @vendors
    #   temp = fsu.watch vendor
    #   temp.on 'create', (FnUtil.proxy @on_fs_change, src, 'create')
    #   temp.on 'change', (FnUtil.proxy @on_fs_change, src, 'change')
    #   temp.on 'delete', (FnUtil.proxy @on_fs_change, src, 'delete')

  on_fs_change:(src, ev, f)=>
    # skip all folder creation
    return if f.type == "dir" and ev == "create"

    # file-path, source-path, and alias
    fpath = f.location
    spath = src.path
    if src.alias isnt ''
      falias = (path.sep + src.alias) 
    else
      falias = ''

    # check if it's from some excluded folder
    include = true
    include &= !(new RegExp( item ).test fpath) for item in @exclude
    return unless include

    # Titleize the type for use in the log messages bellow
    type = StringUtil.titleize f.type

    # relative filepath (with alias, if informed)
    relative_path = fpath.replace spath, falias
    relative_path = (relative_path.substr 1) if relative_path[0] is path.sep

    # date for CLI notifications
    now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

    # switch over created, deleted, updated and watching
    switch ev

      # when a new file is created
      when "create"

        # cli filepath
        msg = "#{('New ' + f.type + ' created').bold}"
        log "[#{now}] #{msg} #{f.location}".cyan

        # initiate file and adds it to the array
        @files.push script = new Script @, spath, fpath, falias, @cli
        script.compile_to_disk()

      # when a file is deleted
      when "delete"

        # removes files from array
        file = ArrayUtil.find @files, 'filepath': relative_path
        return if file is null

        file.item.delete_compiled()
        @files.splice file.index, 1

        # cli msg
        msg = "#{(type + ' deleted, stop watching').bold}"
        log "[#{now}] #{msg} #{f.location}".red

      # when a file is updated
      when "change"

        # updates file information
        file = ArrayUtil.find @files, 'filepath': relative_path

        if file is null
          warn "CHANGED FILE IS APPARENTLY NULL..."
        else
          # cli msg
          msg = "#{(type + ' changed').bold}"
          log "[#{now}] #{msg} #{relative_path}".cyan

          file.item.getinfo()
          file.item.compile_to_disk()

    # if @toaster.before_build is null or @toaster.before_build()
    #   # rebuilds modules
    #   @build()

  compile:()->
    # loop through all ordered files
    file.compile_to_disk() for file, index in @files

  missing = {}
  reorder: (cycling = false) ->
    # log "Module.reorder"

    # if cycling is true or @missing is null, initializes empty array
    # for holding missing dependencies
    # 
    # cycling means the redorder method is being called recursively,
    # no other methods call it with cycling = true
    @missing = {} if cycling is false

    # looping through all files
    for file, i in @files

      # if theres no dependencies, go to next file
      continue if !file.dependencies.length && !file.baseclasses.length
      
      # otherwise loop thourgh all file dependencies
      for dep, index in file.dependencies

        filepath = dep.path

        # search for dependency
        dependency = ArrayUtil.find @files, 'filepath': filepath
        dependency_index = dependency.index if dependency?

        # continue if the dependency was already initialized
        continue if dependency_index < i && dependency?

        # if it's found
        if dependency?

          # if there's some circular dependency loop
          if (ArrayUtil.has dependency.item.dependencies, 'filepath': file.filepath)

            # remove it from the dependencies
            file.dependencies.splice index, 1

            # then prints a warning msg and continue
            warn "Circular dependency found between ".yellow +
                 filepath.grey.bold + " and ".yellow +
                 file.filepath.grey.bold
            
            continue

          # otherwise if no circular dependency is found, reorder
          # the specific dependency and run reorder recursively
          # until everything is beautiful
          else
            @files.splice index, 0, dependency.item
            @files.splice dependency.index + 1, 1
            @reorder true
            break

        # otherwise if the dependency is not found
        else if @missing[filepath] != true
          
          # then add it to the @missing hash (so it will be ignored
          # until reordering finishes)
          @missing[filepath] = true

          # move it to the end of the dependencies array (avoiding
          # it from being touched again)
          file.dependencies.push filepath
          file.dependencies.splice index, 1

          # ..and finally prints a warning msg
          warn "#{'Dependency'.yellow} #{filepath.bold.grey} " +
             "#{'not found for file'.yellow} " +
             file.filepath.grey.bold

      # validate if all base classes was properly imported
      file_index = ArrayUtil.find @files, 'filepath': file.filepath
      file_index = file_index.index

      for bc in file.baseclasses
        found = ArrayUtil.find @files, bc, "classname"
        not_found = (found == null) || (found.index > file_index)

        if not_found && !@missing[bc]
          @missing[bc] = true
          warn "Base class ".yellow +
             "#{bc} ".bold.grey +
             "not found for class ".yellow +
             "#{file.classname} ".bold.grey +
             "in file ".yellow +
             file.filepath.bold.grey