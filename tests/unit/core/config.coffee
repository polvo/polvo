path = require 'path'

polvo = require '../../../lib/polvo'
fix_path = path.join __dirname, '..', '..', 'fixtures', 'css-only'
output_css = path.join fix_path, 'public', 'app.css'

describe '[polvo:config]', ->
  it 'should read config just fine', ->
    stdio = err: (->), out: (->)
    options = compile: true, base: fix_path
    compile = polvo options, stdio
    compile.read_config().output.css.should.equal output_css