path = require 'path'
exec = require('child_process').exec
should = require('chai').should()

fix = path.join __dirname, '..', '..', 'fixtures', 'plugins'

describe '[plugins]', ->
  
  afterEach ->
    global.cli_options = global.__nocolor = global.__stdout = null
    delete global.cli_options
    delete global.__nocolor
    delete global.__stdout

  it 'should return full list', ->
    global.cli_options = base: fix
    plugins = require '../../../lib/utils/plugins'
    plugins.length.should.equal 6

  it 'should return full list under subtree and show not found alert ', ->
    out = 0

    global.cli_options = base: path.join fix, 'node_modules', 'a'
    global.__nocolor = true
    global.__stdout = (msg)->
      out++
      info = "info dependency 'y' not installed, can't check if its a plugin"
      msg.should.equal info

    plugins = require '../../../lib/utils/plugins'
    out.should.equal 1
    plugins.length.should.equal 6