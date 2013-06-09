path = require 'path'
fs = require 'fs'
util = require 'util'

fsu = require 'fs-util'

FnUtil = require '../utils/fn-util'
ArrayUtil = require '../utils/array-util'
StringUtil = require '../utils/string-util'
MinifyUtil = require '../utils/minify-util'

Loader = require './optimizer/loader'
VendorsJS = require './optimizer/vendors-js'
# VendorsCSS = require './optimizer/vendors-css'

{log,debug,warn,error} = require '../utils/log-util'


module.exports = class Optimizer

  loader: null
  vendors_js: null

  constructor:( @polvo, @cli, @config, @tentacle )->
    @loader = new Loader @polvo, @cli, @config, @tentacle, @
    @vendors_js = new VendorsJS @polvo, @cli, @config, @tentacle, @

  copy_vendors_to_release:( all, specific, log_time )->
    @vendors_paths = @vendors_js.copy_to_release all, specific, log_time

  write_amd_loader:->
    @loader.write_amd_loader @vendors_paths

  optimize:->
    # if merge is set, optimization will just merge everything
    if @config.optimize.merge?
      return @merge_everything()

    log 'Optimizing project...'

    # paths = {}
    # layers = []
    # included = []
    # ordered = @reorder (@tree.files.slice 0)

    # for layer_name, layer_deps of @config.browser.optimize.layers

    #   layers.push layer_name

    #   contents = ''
    #   for dep in layer_deps

    #     # gets dependency chain
    #     found = (ArrayUtil.find ordered, 'filepath': "#{dep}.coffee")

    #     # if nothing is found
    #     unless found?
    #       # checks if it was already included
    #       is_included = (ArrayUtil.find included, 'filepath': "#{dep}.coffee")

    #       # and if not..
    #       unless is_included?
    #         msg = "Cannot find module `#{dep}` for layer `#{layer_name}`."
    #         msg += '\nCheck your config file.'
    #         error msg

    #       continue

    #     # scripts pack (all dependencies resolved)
    #     pack = ordered.splice 0, found.index + 1

    #     # adding all to included array
    #     included = included.concat pack

    #     # increments the layer contents and map the script location into paths
    #     for script in pack
    #       paths[script.filepath.replace '.coffee', ''] = layer_name
    #       contents += script.compile_to_str @config

    #   # if there's something to be written
    #   if contents isnt ''

    #     if @config.browser?.optimize?.minify
    #       contents = MinifyUtil.min contents

    #     # write layer
    #     layer_path = path.join @config.output_dir, "#{layer_name}.js"
    #     fs.writeFileSync layer_path, contents

    #     # notify user through cli
    #     relative_path = layer_path.replace @polvo.basepath, ''
    #     relative_path = relative_path.substr 1 if relative_path[0] is path.sep
    #     msg = "#{'✓ Layer optimized: '.bold}#{layer_name} -> #{relative_path}"
    #     log msg.green

    #   # otherwise if it's empty just inform user through the cli
    #   else
    #     msg = "#{'✓ Layer is empty: '.bold} #{layer_name} -> [skipped]"
    #     log msg.yellow

    # # write polvo loader and initializer
    # switch @config.browser.module_system
    #   when 'amd'
    #     @loader.write_loader paths
    #   when 'cjs'
    #     null
    #    # implement
    #   when 'none'
    #     null
    #     # pure javascript libraries can only be merged into a `single.js` file

    # # copy all vendors as well
    # @vendors_js.copy_to_release true, null, false


  merge_files:( after_merge )->
    buffer = []
    for file in (@reorder @tentacle.get_all_files())
      file.compile_to_str (( code ) => buffer.push code), true
    buffer.join '\n'


  merge_everything:->
    console.log 'Merging files..'.grey

    buffer = "//---------------------------------------- amd loader\n\n\n"
    buffer += @loader.get_amd_loader()

    buffer += "//---------------------------------------- vendors\n\n\n"
    buffer += @vendors_js.merge_to_str() + '\n\n'

    buffer += "//---------------------------------------- files\n\n\n"
    buffer += @merge_files() + '\n'

    buffer += "//---------------------------------------- amd initializer\n\n\n"
    buffer += "require( ['#{@config.main_module}'] );"

    if @config.optimize?.minify
      console.log 'Minifying..'.grey
      buffer = MinifyUtil.min buffer

    location = path.join @config.destination, @config.index
    fs.writeFileSync location, buffer

    location = location.replace @polvo.basepath, ''
    log 'Project merged at: ' + location.green


  missing = {}
  reorder: (files, cycling = false) ->

    # if cycling is true initializes empty array to keep missing dependencies
    # cycling=true means the reorder method is being called recursively,
    # no other methods call it with cycling=true
    if cycling is false
      @missing = {}

    # looping through all files
    for file, file_index in files

      # if theres no dependencies, go to next file
      if !file.dependencies.length && !file.baseclasses.length
        continue

      # otherwise loop thourgh all file dependencies
      for dep, index in file.dependencies

        # skip vendors
        if dep.vendor
          continue

        id = dep.id

        # search for dependency
        dependency = ArrayUtil.find files, 'id': id
        dependency_index = dependency.index if dependency?

        # continue if the dependency was already initialized
        if dependency_index < file_index && dependency?
          continue

        # if it's found
        if dependency?

          # if there's some circular dependency loop
          if (ArrayUtil.has dependency.item.dependencies, 'id': file.id)

            # remove it from the dependencies
            file.dependencies.splice index, 1

            # then prints a warning msg and continue
            warn "Circular dependency found between ".yellow +
                 id.grey.bold + " and ".yellow +
                 file.id.grey.bold

            continue

          # otherwise if no circular dependency is found, reorder
          # the specific dependency and run reorder recursively
          # until everything is beautiful
          else
            files.splice file_index, 0, dependency.item
            files.splice dependency.index + 1, 1
            @reorder files, true
            break

        # otherwise if the dependency is not found (for the first time) 
        else if @missing[id] != true

          # then add it to the @missing hash (so it will be ignored
          # until reordering finishes)
          @missing[id] = true

          # move it to the end of the dependencies array (avoiding
          # it from being touched again)
          file.dependencies.push id
          file.dependencies.splice index, 1

          # ..and finally prints a warning msg
          warn "#{'Dependency'.yellow} #{id.bold.grey} " +
             "#{'not found for file'.yellow} " +
             file.id.grey.bold

      # validate if all base classes was properly imported
      file_index = ArrayUtil.find files, 'id': file.id
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
             file.id.bold.grey

    return files