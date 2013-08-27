path = require 'path'
fs = require 'fs'

dirs = require './dirs'
config = require('./config').parse()


map = """
{
  "version": 3,
  "file": "~FILE",
  "sections": [
    ~SECTIONS
  ]
}
"""

section = """{
    "offset": {
      "line":~LINE,
      "column":0
    },
    "map": {
      "version": 3,
      "file": "app.js",
      "sources": ["~SOURCE"],
      "sourcesContent": ["~SOURCE-CONTENT"],
      "names": [],
      "mappings": "~MAPS"
    }
  }
"""

sourcemaps = null

exports.assemble = (files)->

  buffer = map.replace '~FILE', path.basename config.output.js
  sections = []

  for file in files when file.source_map?

    clean_raw = file.raw
    clean_raw = clean_raw.replace /\\/g, '\\\\'
    clean_raw = clean_raw.replace /"/g, '\\"'
    clean_raw = clean_raw.replace /\n/g, '\\n'

    sbuffer = section.replace '~SOURCE', dirs.relative file.filepath
    sbuffer = sbuffer.replace '~LINE', file.source_map_offset
    sbuffer = sbuffer.replace '~MAPS', JSON.parse(file.source_map).mappings
    sbuffer = sbuffer.replace '~SOURCE-CONTENT', clean_raw
    sections.push sbuffer


  sourcemaps = buffer.replace '~SECTIONS', sections.join(',\n')

exports.get_assembled_64 = ->
  new Buffer(sourcemaps).toString 'base64'