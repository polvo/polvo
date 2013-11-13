fs = require 'fs'
path = require 'path'

polvo = require '../../../lib/polvo'
fix_path = path.join __dirname, '..', '..', 'fixtures', 'package-systems'
css_path = path.join fix_path, 'public', 'app.css'

describe '[acceptance] package-systems', ->
  it 'should compile all kinds of requires, showing proper errors', (done)->
    errors = outs = 0
    out_checkers = [
      /✓ public\/app\.js/
      /✓ public\/app\.css/
    ]

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
        out_checkers.shift().test(msg).should.be.true
        if out_checkers.length is 0
          outs.should.equal 2
          errors.should.equal 4

          compiled_css = fs.readFileSync css_path, 'utf-8'
          compiled_css.indexOf('.calendar-table .prev-day,').should.be.above -1

          done()

    compile = polvo options, stdio