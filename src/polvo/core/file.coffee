require('source-map-support').install()


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

  name: null
  dir: null
  relative_path: null
  absolute_path: null

  destination_path: null
  destination_folder: null

  constructor:( @polvo, @cli, @config, @tentacle, @tree, @src_dir, @absolute_path )->
    @compiler = @_resolve_compiler()
    do @refresh

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

    # destination paths
    @out = {}
    @out.absolute_path = path.join @config.destination, @relative_path

    # changing extension for absolute path
    @out.absolute_path = @compiler.translate_ext @out.absolute_path

    # computing other paths
    @out.absolute_dir = path.dirname @out.absolute_path
    @out.relative_path = @out.absolute_path.replace @config.destination, ''

    # source relative path
    @out.relative_path = @out.relative_path.replace /^\//m, ''

  compile_to_str:( after_compile )->
    @compiler.compile @, after_compile

  compile_to_disk:->
    # datetime for CLI notifications
    now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

    # get compiled file
    @compile_to_str (compiled)=>
      # create container folder if it doesnt exist yet
      unless fs.existsSync @out.absolute_dir
        fsu.mkdir_p @out.absolute_dir

      # write compile file inside of it
      fs.writeFileSync @out.absolute_path, compiled

      # notify user through cli
      msg = '✓ Compiled'.bold
      log "[#{now}] #{msg} #{@out.relative_path}".green

  _resolve_compiler:->
    for ext, index in File.EXTENSIONS
      if ext.test @absolute_path
        return File.COMPILERS[index]