fs = require 'fs'
path = require 'path'

jade = require 'jade'
fsu = require 'fs-util'

{log,debug,warn,error} = require '../../utils/log-util'

module.exports = class Handler

  @FILTER = /(?:\/)(?:[^\/_]+)\.jade/m

  constructor: (@toaster, @cli, @config, @tree, @dirpath, @realpath) ->
    @getinfo()

  getinfo:->
    @raw = fs.readFileSync @realpath, "utf-8"

    @filepath = @realpath.replace "#{@dirpath}#{path.sep}", ''
    @filepath = (@filepath.substr 1) if (@filepath.substr 0, 1) is path.sep
    @filename = path.basename @filepath
    @filefolder = path.dirname @filepath

    # compute all necessary release paths
    release_file = path.join @tree.config.output_dir, @filepath
    release_file = release_file.replace '.jade', '.js'
    output_dir = path.dirname release_file

    relative_path = release_file.replace @tree.toaster.basepath, ''
    relative_path = relative_path.substr 1 if relative_path[0] is path.sep

    # this info is used when compiling or deleting from disk, see methods
    # `delete_from_disk` and `compile_to_disk`
    @release = 
      folder: output_dir
      file: release_file
      relative: relative_path

  delete_from_disk:->
    fs.unlinkSync @release.file if (fs.existsSync @release.file)

  compile_to_disk:->
    # datetime for CLI notifications
    now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

    # get compiled javascript
    compiled = do @compile_to_str

    # create container folder if it doesnt exist yet
    fsu.mkdir_p @release.folder unless fs.existsSync @release.folder

    # write compile file inside of it
    fs.writeFileSync @release.file, compiled

    # notify user through cli
    msg = '✓ Compiled'.bold
    log "[#{now}] #{msg} #{@release.relative}".green

  compile_to_str:->
    # TODO: move compile options to config file
    compiled = jade.compile @raw,
      filename: @realpath
      client: true
      compileDebug: false

    compiled = compiled.toString()

    # switch @config.browser.module_system
    #   when 'amd'
        # return @inject_definitions compiled

    @inject_definitions compiled

  inject_definitions:( compiled )->
    # definition = 'define( \'~name\', [], function(){return ~compiled});'
    definition = 'define([], function(){return ~compiled});'
    definition = definition.replace '~compiled', (@to_single_line compiled)
    definition = definition.replace '~name', @filepath

  to_single_line:( text )->
    text