path = require 'path'

polvo = require '../../../lib/polvo'
fix_path = path.join __dirname, '..', '..', 'fixtures', 'css-only'

describe '[polvo:cssonly]', ->
  it 'should build a css-only project fine', (done)->
    errors = outs = 0
    checkers = [
      /✓ public\/app\.css/
    ]

    options = compile: true, base: fix_path
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checkers.shift().test(msg).should.be.true

        checkers.length.should.equal 0
        errors.should.equal 0
        outs.should.equal 1
        done()

    compile = polvo options, stdio