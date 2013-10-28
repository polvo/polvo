path = require 'path'

polvo = require '../../../lib/polvo'
fix_path = path.join __dirname, '..', '..', 'fixtures', 'no-js-output'

describe '[polvo:nojs]', ->
  it 'should alert error about js output', (done)->
    errors = outs = 0
    checkers = [
      /error JS not saved, you need to set the js output in your config file/
      /✓ public\/app\.css/
    ]

    options = compile: true, base: fix_path
    stdio = 
      nocolor: true
      err:(msg) ->
        errors++
        checkers.shift().test(msg).should.be.true
      out:(msg) ->
        outs++
        checkers.shift().test(msg).should.be.true

        checkers.length.should.equal 0
        errors.should.equal 1
        outs.should.equal 1
        done()

    compile = polvo options, stdio