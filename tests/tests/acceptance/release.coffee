fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

polvo = require '../../../lib/polvo'
basic = path.join __dirname, '..', '..', 'fixtures', 'basic'

describe '[acceptance] release', ->

  it 'should release app without any surprises', ->
    errors = outs = 0
    checker = /✓ public\/app\.(js|css).+$/m

    options = release: true, base: basic
    stdio = 
      err:(msg) -> errors++
      out:(msg) ->
        checker.test(msg).should.be.true
      nocolor: true

    release = polvo options, stdio
    errors.should.equal 0


  it 'should release app using --split without any surprises', (done)->
    errors = outs = 0
    checker = ///
      (
        ✓ public/__split__/polvo/tests/fixtures/
        (
          basic/mapped/src/lib.js
          | basic/src/app/app.js
          | basic/src/app/vendor-hold.js
          | basic/src/templates/_header.js
          | basic/src/templates/top.js
          | basic/vendors/another.vendor.js
          | basic/vendors/some.vendor.js
        ).+
      )?
      |(✓ public/app.js)
      |(✓ public/app.css)
    ///

    options = release: true, base: basic, split: true
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        checker.test(msg).should.be.true
        if ++outs is 9
          errors.should.equal 0
          done()

    compile = polvo options, stdio


  it 'should release and serve app without any surprises', (done)->

    errors = outs = 0
    checkers = ///
      (
        public/app.js
        |public/app.css
        |http://localhost:8080
      ).*
    ///

    options = release: true, server: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        checkers.test(msg).should.be.true
        if ++outs is 3
          new setTimeout ->
            server.close()
            errors.should.equal 0
            done()
          , 500

    server = polvo options, stdio