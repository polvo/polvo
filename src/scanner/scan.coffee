fs = require 'fs'
path = require 'path'

_ = require 'lodash'
esprima = require 'esprima'

fsu = require 'fs-util'

dirs = require '../utils/dirs'
config = require('../utils/config').parse()
resolve = require './resolve'


exports.dependencies = (filepath, raw)->
  aliased = {}
  for dep in filter_dependencies esprima.parse raw
    aliased[dep] = resolve filepath, dep
  aliased

exports.dependents = (file, filepath, raw)->
  files = []
  for dirpath in config.input
    for filepath in fsu.find dirpath, file.compiler.ext
      continue if filepath is file.filepath
      files.push
        filepath: filepath
        raw: fs.readFileSync(filepath).toString()

  file.compiler.resolve_dependents file.filepath, files


filter_dependencies = (node, found = [])->

  if node instanceof Array
    for item in node
      filter_dependencies item, found

  else if node instanceof Object
    for key, item of node
      filter_dependencies item, found


  if node instanceof Object
    is_exp = node?.type is 'CallExpression'
    is_idf = node?.callee?.type is 'Identifier'
    is_req = node?.callee?.name is 'require'
    is_lit = node?.arguments?[0]?.type is 'Literal'

    if is_exp and is_idf and is_req and is_lit
      found.push node.arguments[0].value

  found