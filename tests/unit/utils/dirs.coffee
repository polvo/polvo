path = require 'path'
dirs = require '../../../lib/utils/dirs'
should = require('chai').should()

base = path.join __dirname, '..', '..', 'mocks', 'basic'
app = path.join base, 'src', 'app.coffee'
rel = path.relative base, app

describe '[dirs]', ->
  it 'getting pwd', ->
    pwd = path.join __dirname, '..', '..', '..'
    dirs.pwd().should.equal pwd

  it 'getting root', ->
    pwd = path.join __dirname, '..', '..', '..'
    dirs.root().should.equal pwd

  it 'getting pwd after --base inject', ->
    global.global_options = base: base
    dirs.pwd().should.equal base
    global.global_options = null
    delete global.global_options

  it 'getting pwd for inexistent base path', (done)->
    out = 0
    err_msg = 'error Dir informed with [--base] option doesn\'t exist ~> '
    err_msg += 'non/existent/folder'

    global.global_options = base: 'non/existent/folder'

    global.__stdout = (data)-> out++
    global.__stderr = (data)->
      out.should.equal 0
      data.should.equal err_msg
      done()
    
    dirs.pwd()
    global.global_options = null
    delete global.global_options

  it 'getting relative path', ->
    global.global_options = base: base
    dirs.relative(app).should.equal rel
    global.global_options = null
    delete global.global_options