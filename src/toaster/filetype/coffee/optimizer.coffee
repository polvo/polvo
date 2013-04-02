require('source-map-support').install()

fsu = require 'fs-util'
ArrayUtil = require '../../utils/array-util'
FnUtil = require '../../utils/fn-util'
ArrayUtil = require '../../utils/array-util'
StringUtil = require '../../utils/string-util'
MinifyUtil = require '../../utils/minify-util'

{log,debug,warn,error} = require '../../utils/log-util'

path = require 'path'
fs = require 'fs'
util = require 'util'

module.exports = class Optimizer
  constructor:( @toaster, @cli, @config, @tree )->
    # console.log 'OPTIMIZER --------------------->'
    # console.log @toaster
    # console.log @cli
    # console.log @config
    # console.log @tree
    # console.log "................................"

  optimize_for_development:->
    if @config.browser?
      @copy_vendors_to_release()

      if @config.browser.amd
        @write_loader()

  optimize:()->

      unless @config.browser?.optimize?
        return

      # clear release folder
      @tree.clear_release_dir()

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
      @copy_vendors_to_release true, null, false



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

    return files

   merge_everything:->
    console.log 'Merging files..'.grey
    buffer = "//---------------------------------------- vendors\n"
    buffer += @merge_vendors() + '\n\n'

    if @config.browser.amd?
      buffer += "//---------------------------------------- amd loader\n"
      buffer += @_get_amd_loader()

    buffer += "//---------------------------------------- files\n"
    buffer += @merge_files() + '\n'

    if @config.browser?.optimize?.minify
      console.log 'Minifying..'.grey
      buffer = MinifyUtil.min buffer

    location = path.join @config.release_dir, @config.browser.optimize.merge
    fs.writeFileSync location, buffer

    location = location.replace @toaster.basepath, ''
    log 'Project merged at: ' + location.green

  merge_files:->
    buffer = []
    for file in (@reorder (@files.slice 0))
      buffer.push file.compile_to_str @config

    buffer.join '\n'

  merge_vendors:->
    buffer = []
    for vname, vpath of @config.vendors
      buffer.push (fs.readFileSync vpath)

    buffer.join '\n'

  write_loader:( paths )->
    return unless @config.browser.optimize? and @config.browser.amd

    # increment map with all remote vendors
    paths or= {}
    for name, url of @config.vendors
      paths[name] = url if /^http/m.test url

    # mounting main toaster file, contains the toaster builtin amd loader, 
    # all the necessary configs and a hash map containing the layer location
    # for each module that was merged into it.

    loader = @_get_amd_loader()

    if paths?
      paths = (util.inspect paths).replace /\s/g, ''
    else paths = ''

    loader += """\n\n
      /*************************************************************************
       * Automatic configuration by CoffeeToaster.
      *************************************************************************/

      require.config({
        baseUrl: '#{@config.browser.amd.base_url}',
        paths: #{paths}
      });
      require( ['#{@config.browser.amd.main}'] );

      /*************************************************************************
       * Automatic configuration by CoffeeToaster.
      *************************************************************************/
    """

    # writing to disk
    release_path = path.join @config.release_dir, @config.browser.amd.boot

    if @config.browser.optimize.minify && @cli.r
      loader = MinifyUtil.min loader

    fs.writeFileSync release_path, loader


  # copy vendors to release folder
  copy_vendors_to_release:( all = true, specific = null, log_time = true )->

    return unless @config.browser.vendors?

    for vname, vurl of @config.browser.vendors
      unless /^http/m.test vurl

        continue if all is false and vurl isnt specific

        release_path = path.join @config.release_dir, "#{vname}.js"
        fsu.cp vurl, release_path

        from = vurl.replace @toaster.basepath, ''
        to = release_path.replace @toaster.basepath, ''

        from = from.substr 1 if from[0] is path.sep
        to = to.substr 1 if to[0] is path.sep

        # date for CLI notifications
        now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

        msg = if log_time then "[#{now}] " else ""
        msg += "#{'✓ Vendor copied: '.bold}#{from} -> #{to}"

        log msg.green


  _get_amd_loader:->
    rjs_path = path.join @toaster.toaster_base, 'node_modules'
    rjs_path = path.join rjs_path, 'requirejs', 'require.js'
    fs.readFileSync rjs_path, 'utf-8'