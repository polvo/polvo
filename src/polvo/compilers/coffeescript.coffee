require('source-map-support').install()

cs = require 'coffee-script'
{XRegExp} = require 'xregexp'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Coffeescript

  @EXT = /\.(lit)?(coffee)(\.md)?$/m

  AMD_WRAPPER = """
  ###
    rendered with coffeescript
  ###
  ~global_code
  define ['require', 'exports', 'module'], (require, exports, module)->
  ~code
  """

  @compile:( file, after_compile )->
    # caches the file contents
    raw = file.raw

    # filter code that must to be outside of the 'define' block
    global_reg = XRegExp('#>>\n(.*)\n#<<', 's')
    global_res = XRegExp.exec file.raw, global_reg
    global_code = if global_res? then global_res[1] else ''

    # remove the block from the cache
    clean = raw.replace global_code, ''

    # merge everything
    contents = AMD_WRAPPER.replace '~global_code', global_code
    contents = contents.replace '~code', (@reindent clean)

    try
      compiled = cs.compile contents, bare: 1
    catch err
      # catches and shows it, and abort the compilation
      # msg = err.message.replace '"', '\\"'
      # msg = "#{msg.white} @ " + "#{@filepath}".bold.red
      return error err.message + ' at ' + file.relative_path

    # wrapped = AMD_WRAPPER.replace '~code', compiled
    # wrapped = "#{global_code}\n\n#{wrapped}"

    after_compile compiled

  @translate_ext:( filepath )->
    return filepath.replace @EXT, '.js'

  @strip_ext:( filepath )->
    return filepath.replace @EXT, ''

  @reindent:( code )->
    # detect file identation style..
    match_identation = /^(\s+).*$/mg
    identation = ''
    while not (identation.match /^[ \t]{2,}/m)?
      identation = (match_identation.exec code)
      if identation?
        identation = identation[1]
      else
        identation = "  "

    # and reident content (will be wrapped by AMD closures)
    indented = code.replace /^/mg, "#{identation}"