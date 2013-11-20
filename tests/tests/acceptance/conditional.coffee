fs = require 'fs'
fsu = require 'fs-util'

path = require 'path'
exec = require('child_process').exec

polvo = require '../../../lib/polvo'
conditional = path.join __dirname, '..', '..', 'fixtures', 'conditional'

codes = 
  node: "code = 'NODE'"
  browser: "code = 'BROWSER'"
  universal: "code = 'UNIVERSAL'"

describe.only '[acceptance] conditional compilation', ->

  it 'should compile app with ENV=node', ->

    errors = outs = 0
    checker = /✓ lib\/app-node.js.+$/m

    options = compile: true, base: conditional
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    process.env.ENV = 'node'
    compile = polvo options, stdio

    file = path.join conditional, 'lib', 'app-node.js'
    contents = fs.readFileSync file, 'utf-8'
    contents.indexOf(codes.node).should.be.greaterThan -1
    contents.indexOf(codes.browser).should.equal -1
    contents.indexOf(codes.universal).should.equal -1

    outs.should.equal 1
    errors.should.equal 0

  it 'should compile app with ENV=browser', ->

    errors = outs = 0
    checker = /✓ lib\/app-browser.js.+$/m

    options = compile: true, base: conditional
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    process.env.ENV = 'browser'
    compile = polvo options, stdio

    file = path.join conditional, 'lib', 'app-browser.js'
    contents = fs.readFileSync file, 'utf-8'
    contents.indexOf(codes.node).should.equal -1
    contents.indexOf(codes.browser).should.be.greaterThan 1
    contents.indexOf(codes.universal).should.equal -1

    outs.should.equal 1
    errors.should.equal 0

  it 'should compile app with ENV=universal', ->

    errors = outs = 0
    checker = /✓ lib\/app-universal.js.+$/m

    options = compile: true, base: conditional
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    process.env.ENV = 'universal'
    compile = polvo options, stdio

    file = path.join conditional, 'lib', 'app-universal.js'
    contents = fs.readFileSync file, 'utf-8'
    contents.indexOf(codes.node).should.equal -1
    contents.indexOf(codes.browser).should.be.equal -1
    contents.indexOf(codes.universal).should.greaterThan -1

    outs.should.equal 1
    errors.should.equal 0