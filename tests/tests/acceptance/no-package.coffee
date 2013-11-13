fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

polvo = require '../../../lib/polvo'
basic = path.join __dirname, '..', '..', 'fixtures', 'basic'
packg = path.join basic, 'package.json'

describe '[acceptance] manifest file (package.json)', ->

  backup = null

  beforeEach ->
    backup = fs.readFileSync packg, 'utf-8'
    fs.unlinkSync packg

  afterEach ->
    fs.writeFileSync packg, backup

  it 'should alert about no app\'s `package.json` file during compile', ->
    errors = outs = 0
    checker = /^info app doesn't have a `package.json`/m

    options = compile: true, base: basic
    stdio = 
      nocolor: true
      err:(msg)-> errors++
      out:(msg)->
        if outs is 0
          checker.test(msg).should.be.true
          outs++

    compile = polvo options, stdio
    outs.should.equal 1
    errors.should.equal 0