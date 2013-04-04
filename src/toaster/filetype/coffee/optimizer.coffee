require('source-map-support').install()

path = require 'path'
fs = require 'fs'
util = require 'util'

fsu = require 'fs-util'

ArrayUtil = require '../../utils/array-util'
FnUtil = require '../../utils/fn-util'
ArrayUtil = require '../../utils/array-util'
StringUtil = require '../../utils/string-util'
MinifyUtil = require '../../utils/minify-util'

Loader = require './optimizer/loader'
Vendors = require './optimizer/vendors'

{log,debug,warn,error} = require '../../utils/log-util'


module.exports = class Optimizer

  loader: null
  vendors: null

  constructor:( @toaster, @cli, @config, @tree )->
    @loader = new Loader @toaster, @cli, @config, @tree, @
    @vendors = new Vendors @toaster, @cli, @config

  optimize_for_development:->
    if @config.browser?
      @vendors.copy_to_release()
      if @config.browser.module_system is 'amd'
        @loader.write_loader()
      else
        @loader.write_basic_loader()

  optimize:->

    unless @config.browser?.optimize?
      console.error 'No optimization routine set. Check your config file.'
      return

    # clear release folder
    @tree.clear_output_dir()

    # if merge is set, optimization will just merge everything
    if @config.browser.optimize.merge?
      return @merge_everything()

    log 'Optimizing project...'

    paths = {}
    layers = []
    included = []
    ordered = @reorder (@tree.files.slice 0)

    for layer_name, layer_deps of @config.browser.optimize.layers

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
          contents += script.compile_to_str @config

      # if there's something to be written
      if contents isnt ''

        if @config.browser?.optimize?.minify
          contents = MinifyUtil.min contents

        # write layer
        layer_path = path.join @config.output_dir, "#{layer_name}.js"
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
    switch @config.browser.module_system
      when 'amd'
        @loader.write_loader paths
      when 'cjs'
        null
       # implement
      when 'none'
        null
        # pure javascript libraries can only be merged into a `single.js` file

    # copy all vendors as well
    @vendors.copy_to_release true, null, false


  merge_files:->
    buffer = []
    for file in (@reorder (@tree.files.slice 0))
      buffer.push file.compile_to_str @config, false

    buffer.join '\n'


  merge_everything:->
    console.log 'Merging files..'.grey

    buffer = ""

    if @config.browser.module_system is 'amd'
      buffer += "//---------------------------------------- amd loader\n\n\n"
      buffer += @loader.get_amd_loader()

    buffer += "//---------------------------------------- vendors\n\n\n"
    buffer += @vendors.merge_to_str() + '\n\n'

    buffer += "//---------------------------------------- files\n\n\n"
    buffer += @merge_files() + '\n'

    if @config.browser.module_system is 'amd'
      buffer += "//---------------------------------------- amd initializer\n\n\n"
      buffer += "require( ['#{@config.browser.main_module}'] );"

    if @config.browser?.optimize?.minify
      console.log 'Minifying..'.grey
      buffer = MinifyUtil.min buffer

    location = path.join @config.output_dir, @config.browser.optimize.merge
    fs.writeFileSync location, buffer

    location = location.replace @toaster.basepath, ''
    log 'Project merged at: ' + location.green


  missing = {}
  reorder: (files, cycling = false) ->
    # log "Module.reorder"

    # if cycling is true or @missing is null, initializes empty array
    # for holding missing dependencies
    # 
    # cycling means the reorder method is being called recursively,
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
        continue if dep.vendor

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

    # makes sure the main file goes in first place
    if cycling is false
      
      # but only in case amd/cjs isnt in use
      if @config.browser.module_system is 'none'
        main = @config.browser.main_module + '.coffee'

        index = (ArrayUtil.find files, 'filepath': main)?.index

        if index?
          files.splice 0, 0, (files.splice index, 1 )[0]

    return files