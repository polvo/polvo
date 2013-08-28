fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

polvo = require '../../lib/polvo'

# basic mock
basic = path.join __dirname, '..', 'mocks', 'basic'
basic_files = 
  basic_pack: path.join basic, 'package.json'
  app: path.join basic, 'src', 'app', 'app.coffee'
  basic_config: path.join basic, 'polvo.yml'
  js: path.join basic, 'public', 'app.js'
  css: path.join basic, 'public', 'app.css'

basic_config = """
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

basic_pack = '{"name": "basic"}'


# npm mock



describe '[polvo]', ->

  before ->
    fs.unlinkSync basic_files.basic_config if fs.existsSync basic_files.basic_config
    fs.unlinkSync basic_files.basic_pack if fs.existsSync basic_files.basic_pack
    fs.unlinkSync basic_files.js if fs.existsSync basic_files.js
    fs.unlinkSync basic_files.css if fs.existsSync basic_files.css

    fs.writeFileSync basic_files.basic_config, basic_config

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
    fs.unlinkSync basic_files.basic_config if fs.existsSync basic_files.basic_config
    fs.unlinkSync basic_files.basic_pack if fs.existsSync basic_files.basic_pack
    fs.unlinkSync basic_files.js if fs.existsSync basic_files.js
    fs.unlinkSync basic_files.css if fs.existsSync basic_files.css


  it 'should alert about no `package.json` file plugins during compile', ->
    errors = outs = 0
    checker = /^info app doesn't have a `package.json`/m

    options = compile: true, base: basic
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

    options = compile: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    fs.writeFileSync basic_files.basic_pack, basic_pack
    compile = polvo options, stdio

    outs.should.equal 2
    errors.should.equal 0


  it 'should release project without any surprises', ->
    errors = outs = 0
    checker = /✓ public\/app\.(js|css).+$/m

    options = release: true, base: basic
    stdio = 
      out:(msg) -> checker.test(msg).should.be.true
      err:(msg) -> errors++
      nocolor: true

    fs.writeFileSync basic_files.basic_pack, basic_pack
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

    fs.writeFileSync basic_files.basic_pack, basic_pack
    version = polvo options, stdio

    outs.should.equal 1
    errors.should.equal 0

  it 'should start app and perform crate/change/delete files events in watch mode', (done)->
    @timeout 6000 

    errors = outs = 0
    checkers = [
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/

      /\• src\/app\/app.coffee/
      /✓ public\/app\.js/

      /\- src\/app\/app.coffee/
      /✓ public\/app\.js/

      /\+ src\/app\/app\.coffee/
      /✓ public\/app\.js/
    ]

    options = watch: 'true', base: basic
    stdio = 
      out:(msg) ->
        checkers.shift().test(msg).should.be.true
        if checkers.length is 0
          watch.close()
          errors.should.equal 0
          done()

      err:(msg) -> errors++
      nocolor: true

    fs.writeFileSync basic_files.basic_pack, basic_pack
    backup = fs.readFileSync basic_files.app

    polvo = require '../../lib/polvo'
    watch = polvo options, stdio

    # editing
    new setTimeout ->
      fs.appendFileSync basic_files.app, '\n\na = 1\n'
    , 1000

    # deleting
    new setTimeout ->
      fs.unlinkSync basic_files.app
    , 2000

    # creating
    new setTimeout ->
      fs.writeFileSync basic_files.app, backup
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

    options = compile:true, server: 'true', base: basic
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

    fs.writeFileSync basic_files.basic_pack, basic_pack
    backup = fs.readFileSync basic_files.app

    polvo = require '../../lib/polvo'
    server = polvo options, stdio