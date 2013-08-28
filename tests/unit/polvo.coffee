fs = require 'fs'
path = require 'path'

polvo = require '../../lib/polvo'


base = path.join __dirname, '..', 'mocks', 'basic'
files = 
  pack: path.join base, 'package.json'
  config: path.join base, 'polvo.yml'
  js: path.join base, 'public', 'app.js'
  css: path.join base, 'public', 'app.css'

config = """
input:
  - src

output:
  js: public/app.js
  css: public/app.css

virtual:
  mapped: mapped/src

boot: src/app/app
"""

pack = '{"name": "basic"}'

clear_cache = ->
  mod = require.resolve '../../lib/utils/plugins'
  delete require.cache[mod]

describe '[polvo]', ->

  before ->
    fs.unlinkSync files.config if fs.existsSync files.config
    fs.unlinkSync files.pack if fs.existsSync files.pack
    fs.unlinkSync files.js if fs.existsSync files.js
    fs.unlinkSync files.css if fs.existsSync files.css

    fs.writeFileSync files.config, config

  afterEach ->

  after ->
    fs.unlinkSync files.config if fs.existsSync files.config
    fs.unlinkSync files.pack if fs.existsSync files.pack
    fs.unlinkSync files.js if fs.existsSync files.js
    fs.unlinkSync files.css if fs.existsSync files.css


  it 'should alert about no `package.json` file plugins during compile', ->
    errors = outs = 0
    checker = /^info app doesn't have a `package.json`/m

    options = compile: true, base: base
    stdio = 
      nocolor: true
      err:(msg)-> errors++
      out:(msg)->
        if outs is 0
          checker.test(msg).should.be.true
          outs++

    clear_cache()
    compile = polvo options, stdio
    
    outs.should.equal 1
    errors.should.equal 0


  it 'should compile project without any surprises', ->
    errors = outs = 0
    checker = /✓ public\/app\.(js|css).+$/m

    options = compile: true, base: base
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    console.log 'WROTE!', files.pack
    clear_cache()
    fs.writeFileSync files.pack, pack
    compile = polvo options, stdio

    outs.should.equal 2
    errors.should.equal 0


  it 'should release project without any surprises', ->
    errors = outs = 0
    checker = /✓ public\/app\.(js|css).+$/m

    options = release: true, base: base
    stdio = 
      out:(msg) -> checker.test(msg).should.be.true
      err:(msg) -> errors++
      nocolor: true

    compile = polvo options, stdio
    errors.should.equal 0

  it 'version should be printed properly with `polvo -v`', ->
    errors = outs = 0

    options = version: true
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(version) ->
        outs++
        version.should.equal require('../../package.json').version

    compile = polvo options, stdio

    outs.should.equal 1
    errors.should.equal 0