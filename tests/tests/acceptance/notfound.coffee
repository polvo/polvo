path = require 'path'

polvo = require '../../../lib/polvo'
fix_path = path.join __dirname, '..', '..', 'fixtures', 'notfound'

describe '[acceptance] notfound', ->
  it 'should alert simple syntax error on file', (done)->
    errors = outs = 0
    checkers = [
      /error Module '\.\/not\/existent' not found for 'src\/app\.coffee'/
      /✓ public\/app\.js/
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