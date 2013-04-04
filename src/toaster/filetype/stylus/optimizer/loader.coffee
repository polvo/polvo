require('source-map-support').install()

fs = require 'fs'
path = require 'path'
util = require 'util'

{log,debug,warn,error} = require '../../../utils/log-util'

module.exports = class Loader
  constructor:( @toaster, @cli, @config, @tree, @optimizer )->

  write_loader:->
    paths = []
    for file in @tree.files
      filepath = file.filepath.replace @tree.filter, '$1$2'
      paths.push "#{filepath}.css"

    template = '@import url("~SRC");\n'

    buffer = ""
    for src in paths
      buffer += template.replace '~SRC', src

    # writing to disk
    release_path = path.join @config.output_dir, @config.output_file
    fs.writeFileSync release_path, buffer