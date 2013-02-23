FnUtil = require '../utils/fn-util'
ArrayUtil = require '../utils/array-util'
StringUtil = require '../utils/string-util'

Script = require '../core/script'

{log,debug,warn,error} = require '../utils/log-util'

module.exports = class Builder

  # requirements
  fs = require 'fs'
  fsu = require 'fs-util'
  path = require 'path'
  cs = require "coffee-script"
  cp = require "child_process"
  conn = require 'connect'
  util = require 'util'

  watchers: null


  constructor:(@toaster, @cli, @config)->

    # initialize
    @init() if @cli.argv.c or @cli.argv.w or @cli.argv.r

    # starts watching if -w is given
    @watch() if @cli.argv.w

    # starts serving static files
    setTimeout (=> @serve()), 1 if @cli.argv.s

  init:()->

    # initializes buffer array to keep all tracked files
    @files = []

    # loops through all dirs and..
    for dir in @config.dirs

      # searches and collects all *.coffee files inside dir
      for file in (fsu.find dir, /.coffee$/m)

        # check if file should be included or ignored
        include = true
        for item in @config.exclude
          include &= !(new RegExp( item ).test file)

        # if it should be included, add to @files array
        @files.push (new Script @, dir, file) if include

    # clean release folder
    # found = fsu.find @config.release_dir, /.*/, true
    # while found.length
    #   location = found.pop()
    #   if (fs.lstatSync location).isDirectory()
    #     fs.rmdirSync location
    #   else
    #     fs.unlinkSync location

  serve:->
    return if @config.nature_is_node

    # simple static server with 'connect'
    (conn().use conn.static @config.browser.webroot )
      .listen @config.browser.port
    log 'Server running at http://localhost:' + @config.browser.port

  reset:()->
    # close all builder's watchers
    watcher.close() for watcher in @watchers

  watch:()->
    # initialize watchers array
    @watchers = []

    # loops through all dirs
    for dir in @config.dirs

      # and watch them entirely
      @watchers.push (watcher = fsu.watch dir, /.coffee$/m)
      watcher.on 'create', (FnUtil.proxy @on_fs_change, dir, 'create')
      watcher.on 'change', (FnUtil.proxy @on_fs_change, dir, 'change')
      watcher.on 'delete', (FnUtil.proxy @on_fs_change, dir, 'delete')

    # watching vendors for changes
    # for vendor in @vendors
    #   temp = fsu.watch vendor
    #   temp.on 'create', (FnUtil.proxy @on_fs_change, src, 'create')
    #   temp.on 'change', (FnUtil.proxy @on_fs_change, src, 'change')
    #   temp.on 'delete', (FnUtil.proxy @on_fs_change, src, 'delete')

  on_fs_change:(dir, ev, f)=>
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


    # date for CLI notifications
    now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

    # switch over created, deleted, updated and watching
    switch ev

      # when a new file is created
      when "create"

        # cli filepath
        msg = "+ #{type} created".bold
        log "[#{now}] #{msg} #{relative_path}".cyan

        # initiate file and adds it to the array
        @files.push script = new Script @, dir, location
        script.compile_to_disk()

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

        if file is null
          warn "CHANGED FILE IS APPARENTLY NULL..."
        else
          # cli msg
          msg = "• #{type} changed".bold
          log "[#{now}] #{msg} #{relative_path}"

          file.item.getinfo()
          file.item.compile_to_disk()

  clear:->
    # clear release folder
    fsu.rm_rf @config.release_dir
    fsu.mkdir_p @config.release_dir

  compile:()->
    # clear release folder
    @clear()

    # loop through all ordered files
    file.compile_to_disk @config for file, index in @files

    if @config.browser?
      @copy_vendors_to_release()
      @write_loader()

  optimize:()->
    log 'Optimizing project...'

    # clear release folder
    @clear()

    paths = {}
    layers = []
    included = []
    ordered = @reorder (@files.slice 0) # .concat @config.optimize.vendors

    for layer_name, layer_deps of @config.optimize.layers

      layers.push layer_name

      contents = ''
      for dep in layer_deps

        # gets dependency chain
        found = (ArrayUtil.find ordered, 'filepath': "#{dep}.coffee")

        # if nothing is found
        unless found?
          # checks if it was already included
          is_included = (ArrayUtil.find included, 'filepath': "#{dep}.coffee")

          # and if not..
          unless is_included?
            msg = "Cannot find module `#{dep}` for layer `#{layer_name}`."
            msg += '\nCheck your `toaster.coffee` config file.'
            error msg

          continue

        # scripts pack (all dependencies resolved)
        pack = ordered.splice 0, found.index + 1

        # adding all to included array
        included = included.concat pack

        # increments the layer contents and map the script location into paths
        for script in pack
          paths[script.filepath.replace '.coffee', ''] = layer_name
          contents += "#{script.compile_to_str true}"

      # if there's something to be written
      if contents isnt ''
        # write layer
        layer_path = path.join @config.release_dir, "#{layer_name}.js"
        fs.writeFileSync layer_path, contents

        # notify user through cli
        relative_path = layer_path.replace @toaster.basepath, ''
        relative_path = relative_path.substr 1 if relative_path[0] is path.sep
        msg = "#{'✓ Layer optimized: '.bold}#{layer_name} -> #{relative_path}"
        log msg.green

      # otherwise if it's empty just inform user through the cli
      else
        msg = "#{'✓ Layer is empty: '.bold} #{layer_name} -> [skipped]"
        log msg.yellow

    # write toaster loader and initializer
    @write_loader paths

    # copy all vendors as well
    @copy_vendors_to_release()


  write_loader:( paths )->

    return unless @config.optimize?

    # increment map with all remote vendors
    paths or= {}
    for name, url of @config.optimize.vendors
      paths[name] = url if /^http/m.test url

    # mounting main toaster file, contains the toaster builtin amd loader, 
    # all the necessary configs and a hash map containing the layer location
    # for each module that was merged into it.

    octopus_path = path.resolve __dirname
    octopus_path = path.join octopus_path, '..', '..', '..', 'node_modules'
    octopus_path = path.join octopus_path, 'octopus-amd', 'lib'
    octopus_path = path.join octopus_path, 'octopus-amd.js'
    # octopus_path = path.join octopus_path, 'octopus-amd.min.js'

    octopus = fs.readFileSync octopus_path, 'utf-8'

    if paths?
      paths = (util.inspect paths).replace /\s/g, ''
    else paths = ''

    octopus += """\n\n
      /*
       * Toaster automated configuration
       *    -> Configures OctopusAMD.
       */
      OctopusAMD.config({
        base_url: '#{@config.optimize.base_url}',
        paths: #{paths}
      });
      require( ['#{@config.main}'] );
    """

    # writing to disk
    release_path = path.join @config.release_dir, "toaster.js"
    fs.writeFileSync release_path, octopus

  copy_vendors_to_release:( verbose )->
    # copy vendors to release folder
    return unless @config.optimize? and @config.optimize.vendors?
    for vname, vurl of @config.optimize.vendors
      unless /^http/m.test vurl

        release_path = path.join @config.release_dir, "#{vname}.js"
        fsu.cp vurl, release_path
        continue unless verbose

        from = vurl.replace @toaster.basepath, ''
        to = release_path.replace @toaster.basepath, ''

        from = from.substr 1 if from[0] is path.sep
        to = to.substr 1 if to[0] is path.sep

        msg = "#{'✓ Vendor copied: '.bold}#{from} -> #{to}"
        log msg.green


  missing = {}
  reorder: (files, cycling = false) ->
    # log "Module.reorder"

    # if cycling is true or @missing is null, initializes empty array
    # for holding missing dependencies
    # 
    # cycling means the redorder method is being called recursively,
    # no other methods call it with cycling = true
    @missing = {} if cycling is false

    # looping through all files
    for file, i in files

      # if theres no dependencies, go to next file
      continue if !file.dependencies.length && !file.baseclasses.length
      
      # otherwise loop thourgh all file dependencies
      for dep, index in file.dependencies

        filepath = dep.path

        # skip vendors
        continue if filepath[0] is ':'

        # search for dependency
        dependency = ArrayUtil.find files, 'filepath': filepath
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
            files.splice index, 0, dependency.item
            files.splice dependency.index + 1, 1
            @reorder files, true
            break

        # otherwise if the dependency is not found (for the first time) 
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
      file_index = ArrayUtil.find files, 'filepath': file.filepath
      file_index = file_index.index

      for bc in file.baseclasses
        found = ArrayUtil.find files, bc, "classname"
        not_found = (found == null) || (found.index > file_index)

        if not_found && !@missing[bc]
          @missing[bc] = true
          warn "Base class ".yellow +
             "#{bc} ".bold.grey +
             "not found for class ".yellow +
             "#{file.classname} ".bold.grey +
             "in file ".yellow +
             file.filepath.bold.grey

    return files