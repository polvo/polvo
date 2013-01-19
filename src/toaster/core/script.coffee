ArrayUtil = require '../utils/array-util'

module.exports = class Script

  # requires
  fs = require "fs"
  fsu = require 'fs-util'
  path = require 'path'
  cs = require "coffee-script"
  uglify = require("uglify-js").uglify
  uglify_parser = require("uglify-js").parser

  constructor: (@builder, @folderpath, @realpath, @alias, @opts) ->
    @getinfo()



  getinfo:( declare_ns = true )->
    # read file content and initialize dependencies and baseclasses array
    @raw = fs.readFileSync @realpath, "utf-8"
    @dependencies = []
    @baseclasses = []

    # assemble some information about the file
    @filepath = @realpath.replace "#{@folderpath}#{path.sep}", ''

    # computes release paths for saving js files
    @relative_path = @filepath.replace '.coffee', '.js'
    @relative_path = @relative_path.substr 1 if @relative_path[0] is path.sep

    release_path = path.dirname @builder.release
    absolute_path = path.resolve (path.join release_path, @relative_path)

    folder_path = path.dirname absolute_path
    @release = 
      folder: folder_path
      file: absolute_path

    @filepath = (@filepath.substr 1) if (@filepath.substr 0, 1) is path.sep

    @filename = path.basename @filepath
    @filefolder = path.dirname @filepath
    @namespace = ""

    # if the file is in the top level
    if @filepath.indexOf( path.sep ) is -1
      @filefolder = ""


    # assemble namespace info about the file by:
    # 1) replacing "/" or "\" by "."
    @namespace = @filefolder.replace (new RegExp "\\#{path.sep}", "g"), "."
    # 2) excluding first and last ".", if there's one
    @namespace = @namespace.replace /^\.?(.*)\.?$/g, "$1"

    # filter files that have class declarations inside of it
    rgx = /^(class)+\s+([^\s]+)+(\s(extends)\s+([\w.]+))?/mg

    # filter classes that extends another classes
    rgx_ext = /(^|=\s*)(class)\s(\w+)\s(extends)\s(\\w+)\s*$/gm


    # if there is a class inside the file
    if @raw.match( rgx )?

      # @classname = @raw.match( rgx )[3]
      @classname = (@raw.match /class\s([^\s]+)/)[1]
      @classpath = "#{@namespace}.#{@classname}"

      # colletcts the base classes, in case some class in the file
      # extends something
      for klass in @raw.match( rgx_ext ) ? []
        baseclass = klass.match( rgx_ext )[5]
        @baseclasses.push baseclass

    # then if there's other dependencies
    require_reg_all = /^([^\s]+)\s*=\s*require\s(?:'|")(.*)(?:'|")/mg
    require_reg_one = /^([^\s]+)\s*=\s*require\s(?:'|")(.*)(?:'|")/m

    if require_reg_all.test @raw

      # collect all and loop through them
      deps = @raw.match require_reg_all
      for dep in deps
        
        # comment line to strip it out from the compiled version
        @raw = @raw.replace dep, "# #{dep}"

        # computes dep name and path
        match = dep.match require_reg_one
        dep =
          name: match[1]
          path: match[2] + '.coffee'

        # if user is under windows, checks and replace any "/" by "\" in
        # file dependencies: TODO: revise this
        # item.path = item.path.replace /(\/)/g, "\\" if path.sep == "\\"

        @dependencies.push dep

    @backup = @raw
    @inject_definitions()

  # inject proper amd definitions if project nature is 'browser'
  inject_definitions:->

    return unless @builder.nature.browser?

    # computes all dependencies and format it as a stringfied array without []
    deps_path = ''
    deps_args = ''

    for dep in @dependencies
      deps_path += "'#{dep.path.replace '.coffee', ''}',\n" 
      deps_args += "#{dep.name}," 

    deps_path = deps_path.slice 0, -1
    deps_args = deps_args.slice 0, -1

    # gets file identation style
    match_identation = /^([\s]+).*$/mg
    identation = ''
    while not (identation.match /^[\s\t]{2,}/m)?
      identation = (match_identation.exec @raw)
      if identation?
        identation = identation[1]
      else
        identation = "  "

    # reident content
    idented = @backup.replace /^/mg, "#{identation}"

    # re-process the raw file with AMD definitions
    @raw = "define [#{deps_path}], ( #{deps_args} )-> \n#{idented}"

    def = @filepath.replace '.coffee', ''
    @defined_raw = "define '#{def}', [#{deps_path}], ( #{deps_args} )-> \n#{idented}"

  delete_compiled_from_disk:->
    fs.unlinkFileSync @release.file if (fs.existsSync @release.folder)

  compile_to_disk:->
    # datetime for CLI notifications
    now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

    # get compiled javascript
    compiled = @compile_to_str()

    # create container folder if it doesnt exist yet
    fsu.mkdir_p @release.folder unless fs.existsSync @release.folder

    # write compile file inside of it
    fs.writeFileSync @release.file, compiled

    # notify user through cli
    console.log "[#{now}] #{'Compiled'.bold} #{@relative_path}".green

  compile_to_str:->
    compiled = cs.compile @raw, bare: @builder.bare

    if @builder.nature.browser? and @builder.cli.argv.r and @builder.minify
      ast = uglify_parser.parse compiled
      ast = uglify.ast_mangle ast
      ast = uglify.ast_squeeze ast
      compiled = uglify.gen_code ast

    return compiled