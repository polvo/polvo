path = require 'path'
fs = require 'fs'

dirs = require './dirs'
config = require './config'

exports.assemble = (files)->

  # main source map root node
  map = 
    version: 3
    file: path.basename config.output.js
    sections: []

  for file in files when file.source_map?

    # source map sections (file's nodes)
    map.sections.push
      offset: 
        line: file.source_map_offset
        column: 0
      map:
        version: 3
        file: 'app.js'
        sources: [dirs.relative file.filepath]
        sourcesContent: [file.raw]
        names: []
        mappings: JSON.parse(file.source_map).mappings

  JSON.stringify map

exports.encode_base64 = (map)->
  new Buffer(map).toString 'base64'