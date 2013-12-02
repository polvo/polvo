fs = require 'fs'
fsu = require 'fs-util'

path = require 'path'
exec = require('child_process').exec

polvo = require '../../../lib/polvo'
conditional = path.join __dirname, '..', '..', 'fixtures', 'conditional'

codes = 

  js:
    node: "code = 'NODE'"
    browser: "code = 'BROWSER'"
    universal: "code = 'UNIVERSAL'"
    notequal: "code = 'NOT BROWSER'"

    node2: "code = 'NODE2'"
    browser2: "code = 'BROWSER2'"
    universal2: "code = 'UNIVERSAL2'"
    notequal2: "code = 'NOT BROWSER2'"


  css:
    node: "font-family: 'NODE'"
    browser: "font-family: 'BROWSER'"
    universal: "font-family: 'OTHER'"
    notequal: "font-family: 'NOT BROWSER'"

    node2: "font-family: 'NODE2'"
    browser2: "font-family: 'BROWSER2'"
    universal2: "font-family: 'OTHER2'"
    notequal2: "font-family: 'NOT BROWSER2'"



describe '[acceptance] conditional compilation', ->

  it 'should compile app with ENV=node', ->

    errors = outs = 0
    checker = /✓ lib\/app-node(\.js|\.css).*$/m

    options = compile: true, base: conditional
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    process.env.ENV = 'node'
    compile = polvo options, stdio

    for kind in 'js css'.split ' '
      file = path.join conditional, 'lib', "app-node.#{kind}"
      
      contents = fs.readFileSync file, 'utf-8'

      contents.indexOf(codes[kind].node).should.be.greaterThan -1
      contents.indexOf(codes[kind].node2).should.be.greaterThan -1

      contents.indexOf(codes[kind].browser).should.equal -1
      contents.indexOf(codes[kind].browser2).should.equal -1

      contents.indexOf(codes[kind].universal).should.equal -1
      contents.indexOf(codes[kind].universal2).should.equal -1

      contents.indexOf(codes[kind].notequal).should.be.greaterThan -1
      contents.indexOf(codes[kind].notequal2).should.be.greaterThan -1

    outs.should.equal 2
    errors.should.equal 0

  it 'should compile app with ENV=browser', ->

    errors = outs = 0
    checker = /✓ lib\/app-browser(\.js|\.css).*$/m

    options = compile: true, base: conditional
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    process.env.ENV = 'browser'
    compile = polvo options, stdio

    for kind in 'js css'.split ' '
      file = path.join conditional, 'lib', "app-browser.#{kind}"
      contents = fs.readFileSync file, 'utf-8'

      contents.indexOf(codes[kind].node).should.equal -1
      contents.indexOf(codes[kind].node2).should.equal -1

      contents.indexOf(codes[kind].browser).should.be.greaterThan 1
      contents.indexOf(codes[kind].browser2).should.be.greaterThan 1

      contents.indexOf(codes[kind].universal).should.equal -1
      contents.indexOf(codes[kind].universal2).should.equal -1

      contents.indexOf(codes[kind].notequal).should.equal -1
      contents.indexOf(codes[kind].notequal2).should.equal -1


    outs.should.equal 2
    errors.should.equal 0

  it 'should compile app with ENV=universal', ->

    errors = outs = 0
    checker = /✓ lib\/app-universal(\.js|\.css).*$/m

    options = compile: true, base: conditional
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    process.env.ENV = 'universal'
    compile = polvo options, stdio

    for kind in 'js css'.split ' '
      file = path.join conditional, 'lib', "app-universal.#{kind}"
      contents = fs.readFileSync file, 'utf-8'

      contents.indexOf(codes[kind].node).should.equal -1
      contents.indexOf(codes[kind].node2).should.equal -1

      contents.indexOf(codes[kind].browser).should.be.equal -1
      contents.indexOf(codes[kind].browser2).should.be.equal -1

      contents.indexOf(codes[kind].universal).should.greaterThan -1
      contents.indexOf(codes[kind].universal2).should.greaterThan -1

      contents.indexOf(codes[kind].notequal).should.be.greaterThan -1
      contents.indexOf(codes[kind].notequal2).should.be.greaterThan -1

    outs.should.equal 2
    errors.should.equal 0