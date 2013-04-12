Question = require './question'

{log,debug,warn,error} = require '../utils/log-util'

module.exports = class Config extends Question

  # requirements
  path = require "path"
  fs = require "fs"

  # variables
  tpl: """
setup

  # ----------------------------------------------------------------------------
  # SERVER

  server:
    root: 'www'
    port: 3000

  # ----------------------------------------------------------------------------
  # FOLDERS

  # source folders
  sources: ['src']

  # excluded folders (if informed, all others will be included)
  exclude: []

  # included folders (if informed, all others will be excluded)
  include: []

  # ----------------------------------------------------------------------------
  # OUTPUT

  # destination dir for everything
  destination: 'www/js'

  # main file to be included in your html, development and release files will
  # have this name (inside destinaton folder)
  index: 'app.js'

  # ----------------------------------------------------------------------------
  # AMD CONFIGS

  # path to reach the `js` folder through http starting from `/`
  base_url: 'js'

  # main module to be loaded
  main_module: 'boot'

  # ----------------------------------------------------------------------------
  # VENDORS

  vendors:{}

  # javascript:
  #   jquery       : 'vendors/jquery.js'
  #   vendor_a     : 'vendors/vendor_a.js'
  #   vendor_b     : 'vendors/vendor_b.js'
  #   mocha        : 'vendors/mocha.js'
  #   chai         : 'vendors/chai.js'

      # vendors that doesn't implements AMD
      #incompatible : ['jquery', 'mocha', 'vendor_a', 'vendor_b']

  # css:
  #   'xyz':  'bla'

  # ----------------------------------------------------------------------------
  # OPTIMIZATION

  optimize:
    minify: false
    merge: true
"""

  constructor:(@basepath)->


  create: =>

    q1 = "Path to your src folder? [src] : "
    q2 = "Path to your release file? [www/js/app.js] : "
    q3 = "Starting from your webroot '/', what's the folderpath to "+
       "reach your release file? (i.e. js) (optional) : "

    @ask q1.magenta, /.+/, (src)=>
      @ask q2.magenta, /.+/, (release)=>
        @ask q3.cyan, /.*/, (httpfolder)=>
          @write src, release, httpfolder



  write:(src, release, httpfolder)=>

    filepath = path.join @basepath, "polvo.coffee"

    rgx = /(\/)?((\w+)(\.*)(\w+$))/
    parts = rgx.exec release
    filename = parts[2]

    if filename.indexOf(".") > 0
      debug = release.replace rgx, "$1$3-debug$4$5"
    else
      debug = "#{release}-debug"

    # NOTE: All paths (src, release, debug, httpfolder) in 'polvo.coffee'
    # are FORDED to be always '/' even when in win32 which wants to use '\'.
    buffer = @tpl.replace "%src%", src.replace /\\/g, "\/"
    buffer = buffer.replace "%release%", release.replace /\\/g, "\/"
    buffer = buffer.replace "%debug%", debug.replace /\\/g, "\/"
    buffer = buffer.replace "%httpfolder%", httpfolder.replace /\\/g, "\/"

    if fs.existsSync filepath
      question = "\tDo you want to overwrite the file: #{filepath.yellow}"
      question += " ? [y/N] : ".white
      @ask question, /.*?/, (overwrite)=>
        if overwrite.match /y/i
          @save filepath, buffer
          process.exit()
    else
      @save filepath, buffer
      process.exit()

  save:(filepath, contents)->
    fs.writeFileSync filepath, contents
    log "#{'Created'.green.bold} #{filepath}"
    process.exit()