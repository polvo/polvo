require('source-map-support').install()

fs = require 'fs'
path = require 'path'

stylus = require 'stylus'
nib = require 'nib'
fsu = require 'fs-util'

{log,debug,warn,error} = require '../../utils/log-util'

module.exports = class Handler

  @FILTER = /(\/)([^\/_]+)(\.styl)/m

  constructor: (@polvo, @cli, @config, @tree, @dirpath, @realpath) ->
    @getinfo()

  getinfo:->
    @raw = fs.readFileSync @realpath, "utf-8"

    @filepath = @realpath.replace "#{@dirpath}#{path.sep}", ''
    @filepath = (@filepath.substr 1) if (@filepath.substr 0, 1) is path.sep
    @filename = path.basename @filepath
    @filefolder = path.dirname @filepath

    # compute all necessary release paths
    release_file = path.join @tree.config.output_dir, @filepath
    release_file = release_file.replace Handler.FILTER, "$1$2.css"
    output_dir = path.dirname release_file

    relative_path = release_file.replace @tree.polvo.basepath, ''
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
    @compile_to_str (css)=>
      # create container folder if it doesnt exist yet
      fsu.mkdir_p @release.folder unless fs.existsSync @release.folder

      # write compile file inside of it
      fs.writeFileSync @release.file, css

      # notify user through cli
      msg = '✓ Compiled'.bold
      log "[#{now}] #{msg} #{@release.relative}".green

  compile_to_str:( after_compile )->
    fullpath = (path.join @polvo.basepath, @dirpath, @filepath)
    # TODO: move compile options to config file
    stylus( @raw )
      .set( 'filename', fullpath )
      .use( nib() )
      .import( 'nib' )
      .render (err, css)->
        throw err if err?
        after_compile css