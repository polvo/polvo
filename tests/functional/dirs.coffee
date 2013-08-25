path = require 'path'
dirs = require '../../lib/utils/dirs'
should = require('chai').should()

describe '[dirs]', ->
  it 'getting pwd', ->
    pwd = path.join __dirname, '..', '..'
    dirs.pwd().should.equal pwd

  it 'getting root', ->
    pwd = path.join __dirname, '..', '..'
    dirs.pwd().should.equal pwd

  it 'getting pwd after --base inject', ->
    global.global_options = base: __dirname
    dirs.pwd().should.equal __dirname
    global.global_options = null
    delete global.global_options