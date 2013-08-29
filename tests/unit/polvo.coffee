fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

polvo = require '../../lib/polvo'

# mock basic
mock_basic = path.join __dirname, '..', 'mocks', 'basic'
mock_basic_files = 
  app: path.join mock_basic, 'src', 'app', 'app.coffee'
  styl: path.join mock_basic, 'src', 'styles', 'top.styl'
  js: path.join mock_basic, 'public', 'app.js'
  dir: path.join mock_basic, 'src', 'app', 'empty'
  css: path.join mock_basic, 'public', 'app.css'
  vendor: path.join mock_basic, 'vendors', 'some.vendor.js'
  partial: path.join mock_basic, 'src', 'templates', '_header.jade'
  mock_basic_pack: path.join mock_basic, 'package.json'
  mock_basic_config: path.join mock_basic, 'polvo.yml'

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


# mock npm
mock_npm = path.join __dirname, '..', 'mocks', 'npm'

# mock error
mock_error = path.join __dirname, '..', 'mocks', 'error'

# mock nofound
mock_notfound = path.join __dirname, '..', 'mocks', 'notfound'

# mocks no-css/js output
mock_nocss = path.join __dirname, '..', 'mocks', 'no-css-output'
mock_nojs = path.join __dirname, '..', 'mocks', 'no-js-output'

# mocks no-css/js output
mock_css_only = path.join __dirname, '..', 'mocks', 'css-only'

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

      '../../lib/scanner/resolve'
      '../../lib/scanner/scan'
    ]

    for m in mods
      mod = require.resolve m
      delete require.cache[mod]

  after ->
    fs.unlinkSync mock_basic_files.mock_basic_config if fs.existsSync mock_basic_files.mock_basic_config
    fs.unlinkSync mock_basic_files.mock_basic_pack if fs.existsSync mock_basic_files.mock_basic_pack
    fs.unlinkSync mock_basic_files.js if fs.existsSync mock_basic_files.js
    fs.unlinkSync mock_basic_files.css if fs.existsSync mock_basic_files.css


  describe '[general]', ->
    it 'should show version number `-v`', ->
      errors = outs = 0

      options = version: true
      stdio = 
        nocolor: true
        err:(msg) -> errors++
        out:(version) ->
          outs++
          version.should.equal require('../../package.json').version

      version = polvo options, stdio

      outs.should.equal 1
      errors.should.equal 0

    it 'should show the help screen `-h`', ->
      errors = outs = 0

      options = help: true
      stdio = 
        nocolor: true
        err:(msg) -> errors++
        out:(help) ->
          outs++
          help.indexOf('Polyvalent cephalopod mollusc').should.not.equal -1
          help.indexOf('Usage').should.not.equal -1
          help.indexOf('Options').should.not.equal -1
          help.indexOf('Examples').should.not.equal -1

      help = polvo null, stdio

      outs.should.equal 1
      errors.should.equal 0


  describe '[mock:basic]', ->
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

    it 'should release and serve project without any surprises', (done)->
      @timeout 2000

      errors = outs = 0
      checkers = [
        /✓ public\/app\.js.+/
        /✓ public\/app\.css.+/
        /♫  http\:\/\/localhost:8080/
      ]

      options = release: true, server: true, base: mock_basic
      stdio = 
        nocolor: true
        err:(msg) -> errors++
        out:(msg) ->
          outs++
          checkers.shift().test(msg).should.be.true
          if checkers.length is 0
            new setTimeout ->
              server.close()
              errors.should.equal 0
              outs.should.equal 3
              done()
            , 500

      fs.writeFileSync mock_basic_files.mock_basic_pack, mock_basic_pack
      server = polvo options, stdio

    it 'should start app and perform some file operations gracefully', (done)->
      @timeout 15000 

      errors = outs = 0
      err_checkers = [
        /error Module '..\/..\/vendors\/some.vendor' not found for 'src\/app\/app.coffee'/
        /error Module '..\/..\/vendors\/some.vendor' not found for 'src\/app\/vendor-hold.coffee'/
      ]
      out_checkers = [
        # fist compilation
        /✓ public\/app\.js.+/
        /✓ public\/app\.css.+/
        /\♫  http:\/\/localhost:8080/

        # updating app.coffee
        /\• src\/app\/app.coffee/
        /✓ public\/app\.js/

        # deleting app.coffee
        /\- src\/app\/app.coffee/
        /✓ public\/app\.js/

        # crating app.coffee
        /\+ src\/app\/app\.coffee/
        /✓ public\/app\.js/

        # updating _header.jade
        /\• src\/templates\/_header\.jade/
        /✓ public\/app\.js/

        # deleting vendor
        /\- vendors\/some\.vendor\.js/
        /✓ public\/app\.js/

        # re-creating a deleted vendor
        /\+ vendors\/some\.vendor\.js/
        /✓ public\/app\.js/

        # updating _header.jade
        /\• vendors\/some\.vendor\.js/
        /✓ public\/app\.js/

        # updating _header.jade
        /\• src\/styles\/top.styl/
        /✓ public\/app\.css/
      ]

      options = watch: true, server: true, base: mock_basic
      stdio = 
        nocolor: true
        err:(msg) ->
          errors++
          err_checkers.shift().test(msg).should.be.true
        out:(msg) ->
          out_checkers.shift().test(msg).should.be.true
          if out_checkers.length is 0
            watch_server.close()
            errors.should.equal 2
            done()

      fs.writeFileSync mock_basic_files.mock_basic_pack, mock_basic_pack
      backup = fs.readFileSync mock_basic_files.app

      watch_server = polvo options, stdio

      # crating empty folder should do nothing
      new setTimeout ->
        fs.mkdirSync mock_basic_files.dir
      , 1000

      # deleting empty folder should do nothing
      new setTimeout ->
        fs.rmdirSync mock_basic_files.dir
      , 2000

      # editing
      new setTimeout ->
        fs.appendFileSync mock_basic_files.app, ' '
      , 3000

      # deleting
      new setTimeout ->
        fs.unlinkSync mock_basic_files.app
      , 4000

      # creating
      new setTimeout ->
        fs.writeFileSync mock_basic_files.app, backup
      , 5000

      # editing a partial
      new setTimeout ->
        fs.appendFileSync mock_basic_files.partial, ' '
      , 6000

      # deleting a vendor
      new setTimeout ->
        fs.unlinkSync mock_basic_files.vendor
      , 7000

      # creating a vendor
      vendor_backup = fs.readFileSync(mock_basic_files.vendor).toString()
      new setTimeout ->
        fs.writeFileSync mock_basic_files.vendor, vendor_backup
      , 8000

      # editing a vendor
      new setTimeout ->
        fs.appendFileSync mock_basic_files.vendor, ' '
      , 9000

      # editing a style
      new setTimeout ->
        fs.appendFileSync mock_basic_files.styl, ' '
      , 10000



    it 'should watch and serve app, reporting 200 and 404 codes', (done)->
      @timeout 5000

      errors = outs = 0
      checkers = [
        /✓ public\/app\.js.+/
        /✓ public\/app\.css.+/
        /♫  http\:\/\/localhost:8080/
      ]

      server = null

      options = compile:true, server: 'true', base: mock_basic
      stdio = 
        nocolor: true
        err:(msg) -> errors++
        out:(msg) ->
          checkers.shift().test(msg).should.be.true
          if checkers.length is 0
            new setTimeout ->
              exec 'curl -I localhost:8080/app.js', (err, stdout, stderr)->
                /HTTP\/1\.1 200 OK/.test(stdout).should.be.true
                exec 'curl -I localhost:8080/fake.js', (err, stdout, stderr)->
                  /HTTP\/1\.1 404 Not Found/.test(stdout).should.be.true
                  exec 'curl -I localhost:8080/route', (err, stdout, stderr)->
                    /HTTP\/1\.1 200 OK/.test(stdout).should.be.true
                    done()
                    server.close()
                    errors.should.equal 0
            , 500

      fs.writeFileSync mock_basic_files.mock_basic_pack, mock_basic_pack
      backup = fs.readFileSync mock_basic_files.app

      polvo = require '../../lib/polvo'
      server = polvo options, stdio


  describe '[mock:npm]', ->
    it 'should compile all kinds of requires, showing proper errors', (done)->
      errors = outs = 0
      out_checker = /✓ public\/app\.js/

      err_checkers = [
        "error Module './local-mod-folder/none' not found for 'src/app.coffee'"
        "error Module 'non-existent-a' not found for 'src/app.coffee'"
        "error Module './non-existent-b' not found for 'src/app.coffee'"
        "error Module 'mod/non-existent' not found for 'src/app.coffee'"
      ]

      options = compile: true, base: mock_npm
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

  describe '[mock:error]', ->
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

  describe '[mock:notfound]', ->
    it 'should alert simple syntax error on file', (done)->
      errors = outs = 0
      checkers = [
        /error Module '\.\/not\/existent' not found for 'src\/app\.coffee'/
        /✓ public\/app\.js/
      ]

      options = compile: true, base: mock_notfound
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

  describe '[mock:not-css-output]', ->
    it 'should alert error about css output', (done)->
      errors = outs = 0
      checkers = [
        /✓ public\/app\.js/
        /error CSS not saved, you need to set the css output in your config file/
      ]

      options = compile: true, base: mock_nocss
      stdio = 
        nocolor: true
        err:(msg) ->
          errors++
          checkers.shift().test(msg).should.be.true

          checkers.length.should.equal 0
          errors.should.equal 1
          outs.should.equal 1
          done()
        out:(msg) ->
          outs++
          checkers.shift().test(msg).should.be.true

      compile = polvo options, stdio

  describe '[mock:not-js-output]', ->
    it 'should alert error about js output', (done)->
      errors = outs = 0
      checkers = [
        /error JS not saved, you need to set the js output in your config file/
        /✓ public\/app\.css/
      ]

      options = compile: true, base: mock_nojs
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

  describe '[mock:css-only]', ->
    it 'should build a css-only project fine', (done)->
      errors = outs = 0
      checkers = [
        /✓ public\/app\.css/
      ]

      options = compile: true, base: mock_css_only
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