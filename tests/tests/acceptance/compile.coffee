fs = require 'fs'
fsu = require 'fs-util'

path = require 'path'
exec = require('child_process').exec

polvo = require '../../../lib/polvo'
basic = path.join __dirname, '..', '..', 'fixtures', 'basic'

describe '[acceptance] compile', ->

  it 'should compile app without any surprises', ->

    errors = outs = 0
    checker = /✓ public\/app\.(js|css).+$/m

    options = compile: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    compile = polvo options, stdio

    outs.should.equal 2
    errors.should.equal 0

  it 'should compile app using --split without any surprises', ->

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

    options = compile: true, base: basic, split: true
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    compile = polvo options, stdio
    outs.should.equal 9
    errors.should.equal 0
    fsu.rm_rf path.join basic, 'public', '__split__'