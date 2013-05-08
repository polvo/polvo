path = require 'path'
fs = require 'fs'
fsu = require 'fs-util'

Coffeescript = require './../compilers/coffeescript'
Jade = require './../compilers/jade'
Stylus = require './../compilers/stylus'

{log,debug,warn,error} = require './../utils/log-util'


module.exports = class File

  @EXTENSIONS = [Coffeescript.EXT, Jade.EXT, Stylus.EXT]
  @COMPILERS = [Coffeescript, Jade, Stylus]

  id: null
  type: null
  name: null

  absolute_path: null
  relative_path: null

  destination_path: null
  destination_folder: null

  dependencies: null
  baseclasses: null

  constructor:( @polvo, @cli, @config, @tentacle, @tree, @src_dir, @absolute_path )->

    Coffeescript.POLVO = Jade.POLVO = Stylus.POLVO = @polvo

    @compiler = @_resolve_compiler()
    @type = @compiler.TYPE
    @tentacle.use @compiler

    do @refresh
    do @compile_to_str

  refresh:->
    @raw = fs.readFileSync @absolute_path, "utf-8"

    # source paths
    @relative_path = @absolute_path.replace @src_dir, ''
    @relative_dir = path.dirname @relative_path
    @name = path.basename @relative_path

    # normalizing source paths
    @relative_path = @relative_path.replace /^\//m, ''
    @relative_dir = @relative_dir.replace /^\//m, ''
    @relative_dir = '' if @relative_dir is '.'

    @id = @compiler.strip_ext @relative_path

    # destination paths
    @out = {}
    @out.absolute_src_path = path.join @config.destination, @relative_path

    if @compiler.translate_map_ext?
      @out.absolute_map_path = @compiler.translate_map_ext @out.absolute_src_path

    # changing extension for absolute path
    @out.absolute_path = @compiler.translate_ext @out.absolute_src_path

    # computing other paths
    @out.absolute_dir = path.dirname @out.absolute_path
    @out.relative_path = @out.absolute_path.replace @config.destination, ''
    @out.relative_path = @out.relative_path.replace /^\//m, ''

  compile_to_str:( after_compile, exclude_anonymous_reqs, compile_dependents )->
    @compiler.compile @, ( js, map, src )=>
      js = @inject_dependencies js, exclude_anonymous_reqs
      if exclude_anonymous_reqs
        js = @exclude_anonymous_reqs js
      after_compile?(js, map, src)
    , compile_dependents

  delete_from_disk:->
    # js
    if fs.existsSync @out.absolute_path
      fs.unlinkSync @out.absolute_path

    # src file (coffee uses it)
    if fs.existsSync @out.absolute_src_path
      fs.unlinkSync @out.absolute_src_path

    # source maps (coffee uses it)
    if fs.existsSync @out.absolute_map_path
      fs.unlinkSync @out.absolute_map_path

  compile_to_disk:( compile_dependents )->
    # datetime for CLI notifications
    now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

    # get compiled file
    @compile_to_str (js, src_map, src)=>
      # create container folder if it doesnt exist yet
      unless fs.existsSync @out.absolute_dir
        fsu.mkdir_p @out.absolute_dir

      # write compile file inside of it
      fs.writeFileSync @out.absolute_path, js

      # if source maps have been generated
      if src_map? and @out.absolute_map_path?
        fs.writeFileSync @out.absolute_map_path, src_map

      # if source is given, put it side by side with the js in order to
      # provide easy source-mapping
      if src?
        fs.writeFileSync @out.absolute_src_path, src

      @tentacle.notify_socket @

      # notify user through cli
      msg = '✓ Compiled'.bold
      log "[#{now}] #{msg} #{@out.relative_path}".green
    , null, compile_dependents

  extract_dependencies:( js_code )->
    @dependencies = []
    @baseclasses = []

    require_reg = /([^\s]+)?(?:\s*=\s*)?(?:require\s*\()(?:'|")(.+)(?:'|")/g

    while (matched = require_reg.exec js_code)

      # computes dep name and path
      dep = 
        name: matched[1]
        id: matched[2]
        vendor: matched[1] is undefined or (matched[2] of @config.vendors.javascript)
        incompatible: matched[2] in @config.vendors.javascript.incompatible

      # and add it to the dependencies array
      if dep.is_vendor is true or dep.name is undefined
        @dependencies.push dep
      else
        @dependencies.splice @dependencies_diff_head++, 0, dep

  inject_dependencies:( js_code, exclude_anonymous_reqs = false )->

    @extract_dependencies js_code

    if @dependencies.length
      paths = []
      for dep in @dependencies
        if exclude_anonymous_reqs and dep.incompatible
          continue
        else
          paths.push dep.id
      paths = ", '#{paths.join "', '"}'"
    else
      paths = ''
    
    search = "define(['require', 'exports', 'module']"
    replace = "define('#{@id}', ['require', 'exports', 'module'#{paths}]"
    
    js_code.replace search, replace

  exclude_anonymous_reqs:( code )->
    reg = /(^\s*require.+$)/mg
    code.replace reg, "/* $1 */"

  _resolve_compiler:->
    for ext, index in File.EXTENSIONS
      if ext.test @absolute_path
        return File.COMPILERS[index]