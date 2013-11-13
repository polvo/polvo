path = require 'path'

polvo = require '../../../lib/polvo'
fix_path = path.join __dirname, '..', '..', 'fixtures', 'no-css-output'

describe '[acceptance] nocss', ->
  it 'should alert error about css output', (done)->
    errors = outs = 0
    checkers = [
      /✓ public\/app\.js/
      /error CSS not saved, you need to set the css output in your config file/
    ]

    options = compile: true, base: fix_path
    stdio = 
      nocolor: true
      err:(msg) ->
        errors++
        checkers.shift().test(msg).should.be.true

        checkers.length.should.equal 0
        errors.should.equal 1
        outs.should.equal 1
        done()
      out:(msg) ->
        outs++
        checkers.shift().test(msg).should.be.true

    compile = polvo options, stdio