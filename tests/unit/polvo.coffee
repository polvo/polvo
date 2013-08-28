fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

polvo = require '../../lib/polvo'


base = path.join __dirname, '..', 'mocks', 'basic'
files = 
  pack: path.join base, 'package.json'
  app: path.join base, 'src', 'app.coffee'
  config: path.join base, 'polvo.yml'
  js: path.join base, 'public', 'app.js'
  css: path.join base, 'public', 'app.css'

config = """
server:
  port: 8080
  root: ./public

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


describe '[polvo]', ->

  before ->
    fs.unlinkSync files.config if fs.existsSync files.config
    fs.unlinkSync files.pack if fs.existsSync files.pack
    fs.unlinkSync files.js if fs.existsSync files.js
    fs.unlinkSync files.css if fs.existsSync files.css

    fs.writeFileSync files.config, config

  afterEach ->
    mods = [
      '../../lib/utils/plugins'
      '../../lib/core/compiler'
      '../../lib/core/file'
      '../../lib/core/files'
      '../../lib/core/server'
    ]

    for m in mods
      mod = require.resolve m
      delete require.cache[mod]

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

    compile = polvo options, stdio
    
    outs.should.equal 1
    errors.should.equal 0


  it 'should compile app without any surprises', ->
    errors = outs = 0
    checker = /✓ public\/app\.(js|css).+$/m

    options = compile: true, base: base
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

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

    fs.writeFileSync files.pack, pack
    release = polvo options, stdio
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

    fs.writeFileSync files.pack, pack
    version = polvo options, stdio

    outs.should.equal 1
    errors.should.equal 0

  it 'should start app and perform crate/change/delete files events in watch mode', (done)->
    @timeout 6000 

    errors = outs = 0
    checkers = [
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/

      /\• src\/app.coffee/
      /✓ public\/app\.js/

      /\- src\/app.coffee/
      /✓ public\/app\.js/

      /\+ src\/app\.coffee/
      /✓ public\/app\.js/
    ]

    options = watch: 'true', base: base
    stdio = 
      out:(msg) ->
        checkers.shift().test(msg).should.be.true
        if checkers.length is 0
          watch.close()
          errors.should.equal 0
          done()

      err:(msg) -> errors++
      nocolor: true

    fs.writeFileSync files.pack, pack
    backup = fs.readFileSync files.app

    polvo = require '../../lib/polvo'
    watch = polvo options, stdio

    # editing
    new setTimeout ->
      fs.appendFileSync files.app, '\n\na = 1\n'
    , 1000

    # deleting
    new setTimeout ->
      fs.unlinkSync files.app
    , 2000

    # creating
    new setTimeout ->
      fs.writeFileSync files.app, backup
    , 3000

  it 'should start app and serve it', (done)->
    @timeout 4000

    errors = outs = 0
    checkers = [
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /♫  http\:\/\/localhost:8080/
    ]

    server = null

    options = compile:true, server: 'true', base: base
    stdio = 
      out:(msg) ->
        checkers.shift().test(msg).should.be.true
        if checkers.length is 0
          new setTimeout ->
            exec 'curl -I localhost:8080', (err, stdout, stderr)->
              /HTTP\/1\.1 200 OK/.test(stdout).should.be.true
              done()
              server.close()
              errors.should.equal 0
          , 500
      err:(msg) -> errors++
      nocolor: true

    fs.writeFileSync files.pack, pack
    backup = fs.readFileSync files.app

    polvo = require '../../lib/polvo'
    server = polvo options, stdio