#<< toaster/utils/array-util

class Script

  # requires
  fs = require "fs"
  path = require 'path'
  cs = require "coffee-script"

  ArrayUtil = toaster.utils.ArrayUtil

  constructor: (@builder, @folderpath, @realpath, @alias, @opts) ->
    @getinfo()



  getinfo:( declare_ns = true )->
    # read file content and initialize dependencies and baseclasses array
    @raw = fs.readFileSync @realpath, "utf-8"
    @dependencies_collapsed = []
    @baseclasses = []

    # assemble some information about the file
    @filepath = @realpath.replace @folderpath, ''
    if @alias?
      @filepath = path.join path.sep, @alias, @filepath
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

      # if the file is not in the root src folder (outside any
      # folder/package ) and packaging is enabled
      if @namespace != "" and @builder.packaging

        # then modify the class declarations before starting
        # the parser thing, adding the package headers declarations
        # as well as the expose thing

        for decl in [].concat (@raw.match rgx)

          # name
          name = (decl.match /class\s([^\s]+)/)[1].split('.').pop()
          
          @classname ?= name

          # extends
          @extending = (decl.match /(\s*extends\s*[^\s]+$)/m)
          @extending = @extending[0] if @extending
          @extending ||= ""

          # file modification (declaring namespaces for classes)
          repl = "class #{@namespace}.#{name}#{@extending}"

          # write full declaration to the file if it's not right yet
          if decl isnt repl
            @raw = @raw.replace decl, repl
            fs.writeFileSync @realpath, @raw

      # @classname = @raw.match( rgx )[3]
      @classname = (@raw.match /class\s([^\s]+)/)[1].split('.').pop()
      @classpath = "#{@namespace}.#{@classname}"

      # colletcts the base classes, in case some class in the file
      # extends something
      for klass in @raw.match( rgx_ext ) ? []
        baseclass = klass.match( rgx_ext )[5]
        @baseclasses.push baseclass

    # then if there's other dependencies
    if /(#<<\s)(.*)/g.test @raw

      # collect all and loop through them
      requirements = @raw.match /(#<<\s)(.*)/g
      for item in requirements
        # 1. filter dependency name
        # 2. trim it 
        # 3. split all dependencies
        # 4. concat it with the dependencies array
        item         = /(#<<\s)(.*)/.exec( item )[ 2 ]
        item         = item.replace /\s/g, ""
        # item         = [].concat item.split ","

        # if user is under windows, checks and replace any "/" by "\" in
        # file dependencies
        item = item.replace /(\/)/g, "\\" if path.sep == "\\"

        @dependencies_collapsed = @dependencies_collapsed.concat item

    @backup = @raw

  # expand all wildcards imports
  expand_dependencies:()->

    # referencies the builder's files array
    files = @builder.files

    # resets the dependencies array
    @dependencies = []

    # looping through file dependencies
    for dependency, index in @dependencies_collapsed

      # normalize first slash / backslash
      if (dependency.substr 0, 1) is path.sep
        dependency = dependency.substr 1

      # if dependency is not a wild-card (namespace.*)
      if dependency.substr(-1) != "*"
        # then add file extension to it and continue
        @dependencies.push "#{path.sep}#{dependency}.coffee"
        continue

      # otherwise find all files under that namespace
      reg = new RegExp dependency.replace /(\/|\\)/g, "\\$1"
      found = ArrayUtil.find_all files, reg, "filepath", true, true

      # if nothing is found under the given namespace
      if found.length <= 0
        warn "Nothing found inside #{("'"+dependency).white}'".yellow
        continue
      
      # otherwise rewrites found array with filepath info only
      for expanded in found
        if expanded.item.filepath isnt @filepath
          @dependencies.push expanded.item.filepath

    @inject_definitions()

    @dependencies

  # inject proper definition based on project nature:
  #   browser -> use AMD definitions
  #   node -> use CommonJS definitions
  inject_definitions:->

    # computes all dependency and format it as a stringfied array without []
    deps = ""
    for dep in @dependencies
      deps += "'#{dep.replace '.coffee', ''}',\n" 
    deps = deps.slice 0, -1

    # first namespace
    ns_root = (@namespace.match /^([^\.]+)/)[1]

    # namespaces after the first
    ns_rest = @namespace.replace "#{ns_root}.", ""

          # AMD (async)
    if @builder.nature is 'browser'

      # gets file identation style
      match_identation = /^([\s]+).*$/mg
      while identation isnt '\s' and identation isnt '\t'
        identation = (match_identation.exec @raw)[1]

      # reident content
      idented = @backup.replace /^/mg, "#{identation}"

      # add defininion
      @raw = "__toast #{ns_root}, '#{ns_rest}'\n"

      # re-process the raw file with AMD definitions
      @raw += "define '#{@classpath}', [#{deps}], -> \n#{idented}"

    # COMMON JS (sync)
    else if @builder.nature is 'node'

      root = "#{ns_root} = {}"
      exp = "exports.#{ns_root} = {}"

      @raw = "{toast} = require './toaster'\n"
      @raw += "__e = toast '#{ns_rest}', #{root}, #{exp}, [ #{deps} ]\n"
      @raw += @backup.replace /(class\s)/g, "__e.#{@classname} = $1"