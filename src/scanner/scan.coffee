fs = require 'fs'
_ = require 'lodash'
fsu = require 'fs-util'
path = require 'path'
esprima = require 'esprima'

resolve = require './resolve'


exports.dependencies = (file, filepath, raw)->
  aliased = {}
  for dep in filter_dependencies esprima.parse raw
    aliased[dep] = resolve filepath, dep
  aliased

exports.dependents = (file, filepath, raw)->
  filter_dependents()

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


filter_dependents = ->
  []