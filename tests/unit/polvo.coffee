fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

polvo = require '../../lib/polvo'

# mock_basic mock
mock_basic = path.join __dirname, '..', 'mocks', 'basic'
mock_basic_files = 
  mock_basic_pack: path.join mock_basic, 'package.json'
  app: path.join mock_basic, 'src', 'app', 'app.coffee'
  mock_basic_config: path.join mock_basic, 'polvo.yml'
  js: path.join mock_basic, 'public', 'app.js'
  css: path.join mock_basic, 'public', 'app.css'

mock_basic_config = """
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

mock_basic_pack = '{"name": "mock_basic"}'


# npm mock
mock_npm = path.join __dirname, '..', 'mocks', 'npm'

# mock_npm mock
mock_error = path.join __dirname, '..', 'mocks', 'error'

describe '[polvo]', ->

  before ->
    fs.unlinkSync mock_basic_files.mock_basic_config if fs.existsSync mock_basic_files.mock_basic_config
    fs.unlinkSync mock_basic_files.mock_basic_pack if fs.existsSync mock_basic_files.mock_basic_pack
    fs.unlinkSync mock_basic_files.js if fs.existsSync mock_basic_files.js
    fs.unlinkSync mock_basic_files.css if fs.existsSync mock_basic_files.css

    fs.writeFileSync mock_basic_files.mock_basic_config, mock_basic_config

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
    fs.unlinkSync mock_basic_files.mock_basic_config if fs.existsSync mock_basic_files.mock_basic_config
    fs.unlinkSync mock_basic_files.mock_basic_pack if fs.existsSync mock_basic_files.mock_basic_pack
    fs.unlinkSync mock_basic_files.js if fs.existsSync mock_basic_files.js
    fs.unlinkSync mock_basic_files.css if fs.existsSync mock_basic_files.css


  it 'should alert about no `package.json` file plugins during compile', ->
    errors = outs = 0
    checker = /^info app doesn't have a `package.json`/m

    options = compile: true, base: mock_basic
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

    options = compile: true, base: mock_basic
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    fs.writeFileSync mock_basic_files.mock_basic_pack, mock_basic_pack
    compile = polvo options, stdio

    outs.should.equal 2
    errors.should.equal 0


  it 'should release project without any surprises', ->
    errors = outs = 0
    checker = /✓ public\/app\.(js|css).+$/m

    options = release: true, base: mock_basic
    stdio = 
      out:(msg) -> checker.test(msg).should.be.true
      err:(msg) -> errors++
      nocolor: true

    fs.writeFileSync mock_basic_files.mock_basic_pack, mock_basic_pack
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

    fs.writeFileSync mock_basic_files.mock_basic_pack, mock_basic_pack
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

    options = watch: 'true', base: mock_basic
    stdio = 
      out:(msg) ->
        checkers.shift().test(msg).should.be.true
        if checkers.length is 0
          watch.close()
          errors.should.equal 0
          done()

      err:(msg) -> errors++
      nocolor: true

    fs.writeFileSync mock_basic_files.mock_basic_pack, mock_basic_pack
    backup = fs.readFileSync mock_basic_files.app

    polvo = require '../../lib/polvo'
    watch = polvo options, stdio

    # editing
    new setTimeout ->
      fs.appendFileSync mock_basic_files.app, '\n\na = 1\n'
    , 1000

    # deleting
    new setTimeout ->
      fs.unlinkSync mock_basic_files.app
    , 2000

    # creating
    new setTimeout ->
      fs.writeFileSync mock_basic_files.app, backup
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

    options = compile:true, server: 'true', base: mock_basic
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

    fs.writeFileSync mock_basic_files.mock_basic_pack, mock_basic_pack
    backup = fs.readFileSync mock_basic_files.app

    polvo = require '../../lib/polvo'
    server = polvo options, stdio

  it 'should compile app with mock_NPM dependencies and index files', (done)->
    errors = outs = 0
    checker = /✓ public\/app\.js/

    options = compile: true, base: mock_npm
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true
        done()

    compile = polvo options, stdio

    outs.should.equal 1
    errors.should.equal 0

  it 'should alert simple syntax error on file', (done)->
    errors = outs = 0
    checkers = [
      /error src\/app\.coffee/
      /✓ public\/app\.js/
    ]

    options = compile: true, base: mock_error
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