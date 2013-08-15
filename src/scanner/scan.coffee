fs = require 'fs'
_ = require 'lodash'
fsu = require 'fs-util'
path = require 'path'
esprima = require 'esprima'

resolve = require './resolve'


module.exports = (filepath, raw)->
  aliased = {}
  for dep in filter_deps esprima.parse raw
    aliased[dep] = resolve filepath, dep

  aliased


filter_deps = (node, found = [])->

  if node instanceof Array
    for item in node
      filter_deps item, found

  else if node instanceof Object
    for key, item of node
      filter_deps item, found


  if node instanceof Object
    is_exp = node?.type is 'CallExpression'
    is_idf = node?.callee?.type is 'Identifier'
    is_req = node?.callee?.name is 'require'
    is_lit = node?.arguments?[0]?.type is 'Literal'

    if is_exp and is_idf and is_req and is_lit
      found.push node.arguments[0].value

  found