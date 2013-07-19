path = require 'path'
{XRegExp} = require 'xregexp'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class javascript

  @NAME = 'javascript'
  @TYPE = 'javascript'
  @EXT = /\.(js)?$/m

  AMD_WRAPPER = """
  /*
    Assembled by Polvo
  */
  ~global_code
  define(['require', 'exports', 'module'], function(require, exports, module)
  {
  ~code
  });
  """

  @compile:( file, after_compile )->
    # caches the file contents
    raw = file.raw

    # filter code that must to be outside of the 'define' block
    global_reg = XRegExp('\/\/>>\n(.*)\n\/\/<<', 's')
    global_res = XRegExp.exec file.raw, global_reg
    global_code = if global_res? then global_res[1] else ''

    # remove the block from the cache
    clean = raw.replace global_code, ''

    # wrap code with AMD signature
    contents = AMD_WRAPPER.replace '~code', (@reindent clean)

    # inject code outside amd wrapper as needed
    contents = contents.replace '~global_code', global_code

    after_compile contents

  @translate_ext:( filepath )->
    return filepath

  @strip_ext:( filepath )->
    return filepath.replace @EXT, ''

  @reindent:( code )->
    # detect file indentation style..
    match_indentation = /^(\s+).*$/mg
    indentation = ''
    while not (indentation.match /^[ \t]{2,}/m)?
      indentation = (match_indentation.exec code)
      if indentation?
        indentation = indentation[1]
      else
        indentation = "  "

    # removing any new line
    indentation = indentation.replace /[\r\n]/g, ''

    # and reident content (will be wrapped by AMD closures)
    return code.replace /^/mg, "#{indentation}"