path = require 'path'

polvo = require '../../../lib/polvo'
fix_path = path.join __dirname, '..', '..', 'fixtures', 'npm'

describe '[polvo:npm]', ->
  it 'should compile all kinds of requires, showing proper errors', (done)->
    errors = outs = 0
    out_checker = /✓ public\/app\.js/

    err_checkers = [
      "error Module './local-mod-folder/none' not found for 'src/app.coffee'"
      "error Module 'non-existent-a' not found for 'src/app.coffee'"
      "error Module './non-existent-b' not found for 'src/app.coffee'"
      "error Module 'mod/non-existent' not found for 'src/app.coffee'"
    ]

    options = compile: true, base: fix_path
    stdio = 
      nocolor: true
      err:(msg) ->
        errors++
        msg.should.equal err_checkers.shift()
      out:(msg) ->
        outs++
        out_checker.test(msg).should.be.true
        outs.should.equal 1
        errors.should.equal 4
        done()

    compile = polvo options, stdio