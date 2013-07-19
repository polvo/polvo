path = require 'path'
fs = require 'fs'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Html

  @NAME = 'html'
  @TYPE = 'template'
  @EXT = /\.(html|htm)$/m

  AMD_WRAPPER = """
  // Assembed by Polvo
  define(['require', 'exports', 'module'], function(require, exports, module)
  {
    module.exports = function()
    {
      return "~code";
    }
  });"""

  @compile:( file, after_compile, compile_dependents )->

    # files starting with a `_` is handled as partials and ignored by default,
    # so in this cases we search for files that imports this partial and compile
    # all of them it instead of the partial itself
    if /^_/m.test file.name
      if compile_dependents
        @compile_dependents file
      return
    
    contents = @render_partials file
    contents = contents.replace /\n/g, ' \\\n'
    
    template = contents.replace /"/g, '\\"'

    wrapped = AMD_WRAPPER.replace '~code', template
    after_compile wrapped

  @translate_ext:( filepath )->
    return filepath.replace @EXT, '.js'

  @strip_ext:( filepath )->
    return filepath.replace @EXT, ''


  @render_partials:( file )->
    include = /\<!--#include\s*file\s*=\s*(?:"|')([^"']+)(?:"|')\s*-->/gm
    contents = file.raw

    while (match = include.exec contents)
      include_path = path.join (path.dirname file.absolute_path), match[1]
      include_path += '.html'

      if fs.existsSync include_path
        include_contents = do (fs.readFileSync include_path).toString
      else
        include_contents = ''
        error "File #{include_path} do not exist"

      contents = contents.replace match[0], include_contents

    return contents

  @compile_dependents:( file )->

    # collect all files
    files = []
    for tentacle in @POLVO.tentacles
      for tree in tentacle.trees
        files = files.concat tree.files

    # loop through them
    has_inc_reg = /\<!--#include\s*file\s*=/gm

    for f in files

      # ignores also files that has different types
      continue if f.type isnt @TYPE

      # ignores also files that doesn't import anything
      continue unless has_inc_reg.test f.raw

      # loop through all found imports on file
      inc_all_reg = /\<!--#include\s*file\s*=\s*(?:"|')([^"']+)(?:"|')\s*-->/gm
      while (match = inc_all_reg.exec f.raw)?

        # translate paths (relative -> absolute)
        import_path = match[1]
        import_dir = path.dirname import_path
        import_file = path.basename import_path

        parent_dir_parts = (path.dirname f.absolute_path).split '/'
        import_dir_parts = import_dir.split '/'

        while (part = import_dir_parts[0]) is '..'
          do import_dir_parts.shift
          do parent_dir_parts.pop

        abs_path = path.normalize [
          parent_dir_parts.join '/'
          import_dir_parts.join '/'
          import_file
        ].join '/'

        # compile current file (f) if it depends on changed file (file)
        cond1 = "#{abs_path}.html" is file.absolute_path
        cond2 = "#{abs_path}.htm" is file.absolute_path

        if cond1 or cond2
          
          # if file in question is another partial, recursively walk it up
          # compiling everything from backwards passing compile_dependents=true,
          # otherwise if file isn't another partial (starting with '_', just
          # compiles it normally passing compile_dependents=false
          compile_dependents = /^_/m.test f.name
          f.compile_to_disk compile_dependents