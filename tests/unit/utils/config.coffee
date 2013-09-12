fs = require 'fs'
path = require 'path'
should = require('chai').should()
# require '../../../lib/utils/config'

base = path.join __dirname, '..', '..', 'fixtures', 'basic'
yml = path.join base, 'polvo.yml'

# helper for writing many config files
write_config = (contents...)->
  buffer =  contents.join '\n\n'
  fs.writeFileSync yml, buffer

# config variations templates
configs = 
  server:
    empty: 'server:\n  root:'
    inexistent: 'server:\n  port: 3000\n  root: not/existent/folder'
    valid: 'server:\n  root: public'
    valid_with_pot: 'server:\n  port:11235\n  root: public'

  input:
    inexistent: 'input:\n  - non/existent/folder'
    valid: 'input:\n  - src'

  output:
    js:
      inexistent: 'output:\n  js: non/existent/folder/app.js'
      valid: 'output:\n  js: public/app.js'
    css:
      inexistent: 'output:\n  css: non/existent/folder/app.css'
      valid: 'output:\n  css: public/app.css'

  alias:
    inexistent: 'alias:\n  mapped: non/existent/folder'
    valid: 'alias:\n  mapped: mapped/src'

  boot:
    empty: 'boot:\n'
    valid: 'boot: src/app\n'

  minify:
    js: off: 'minify:\n  js: false'
    css: off: 'minify:\n  css: false'




describe '[config]', ->

  beforeEach ->
    global.cli_options = base: base

  afterEach ->
    global.cli_options = null
    delete global.cli_options
    
  before ->
    global.__nocolor = true
    global.cli_options = base: base

  after ->
    global.__nocolor = 
    global.__stdout =
    global.__stderr = null

    delete global.__nocolor
    delete global.__stdout
    delete global.__stderr

  afterEach ->
    fs.unlinkSync yml if fs.existsSync yml

  describe '[config not found]', ->
    it 'error should be shown when config file is not found', (done)->
      out = 0
      reg = /error Config file not found ~>.+\/polvo.yml/m

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        reg.test(data).should.be.true
        done()

      require '../../../lib/utils/config'



  describe '[key:input]', ->
    it 'error should be shown when key is not set', (done)->
      out = 0
      err_msg = 'error You need at least one input dir in config file'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config ''
      require '../../../lib/utils/config'

    it 'error should be shown when input dir does not exist', (done)->
      out = 0
      err_msg = 'error Input dir does not exist ~> non/existent/folder'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.inexistent
      require '../../../lib/utils/config'



  describe '[key:output]', ->
    it 'error should be shown when key is not set', (done)->
      out = 0
      err_msg = 'error You need at least one output in config file'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid
      require '../../../lib/utils/config'

    it 'error should be shown when js\'s output dir does not exist', (done)->
      out = 0
      err_msg = 'error JS\'s output dir does not exist ~> non/existent/folder'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid, configs.output.js.inexistent
      require '../../../lib/utils/config'

    it 'error should be shown when css\'s output dir does not exist', (done)->
      out = 0
      err_msg = 'error CSS\'s output dir does not exist ~> non/existent/folder'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid, configs.output.css.inexistent
      require '../../../lib/utils/config'



  describe '[key:alias]', ->

    it 'error should be shown when mapped folder doesn\'t exist', (done)->
      out = 0
      err_msg = 'error Alias \'mapped\' does not exist ~> '
      err_msg += 'non/existent/folder'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid,
                   configs.output.js.valid,
                   configs.output.css.valid,
                   configs.alias.inexistent
      require '../../../lib/utils/config'



  describe '[key:server]', ->
    it 'error should be shown when server key is not set and -s is in use', (done)->
      out = 0
      err_msg = 'error Server\'s config not set in config file'

      global.cli_options.server = true
      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid,
                   configs.output.js.valid,
                   configs.output.css.valid,
                   configs.alias.valid
      require '../../../lib/utils/config'

    it 'error should be shown when server root dir is not set', (done)->
      out = 0
      err_msg = 'error Server\'s root not set in in config file'

      global.cli_options.server = true
      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid,
                   configs.output.js.valid,
                   configs.output.css.valid,
                   configs.alias.valid,
                   configs.server.empty
      require '../../../lib/utils/config'

    it 'error should be shown when server root dir does not exist', (done)->
      out = 0
      root_dir = path.join base, 'not', 'existent', 'folder'
      err_msg = 'error Server\'s root dir does not exist ~> ' + root_dir 

      global.cli_options.server = true
      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid,
                   configs.output.js.valid,
                   configs.output.css.valid,
                   configs.alias.valid,
                   configs.server.inexistent
      require '../../../lib/utils/config'



  describe '[key:boot]', ->
    it 'error should be shown when key is not set', (done)->
      out = 0
      err_msg = 'error Boot module not informed in config file'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid,
                   configs.output.js.valid,
                   configs.output.css.valid,
                   configs.alias.valid,
                   configs.server.valid

      require '../../../lib/utils/config'



  describe '[key:minify]', ->
    it 'minify should be turned on by default', ->
      write_config configs.input.valid,
             configs.output.js.valid,
             configs.output.css.valid,
             configs.alias.valid,
             configs.server.valid,
             configs.boot.valid

      config = require '../../../lib/utils/config'

      should.exist config.minify
      config.minify.css.should.be.true
      config.minify.js.should.be.true

    it 'minify.css may be turned off', ->
      write_config configs.input.valid,
             configs.output.js.valid,
             configs.output.css.valid,
             configs.alias.valid,
             configs.server.valid,
             configs.minify.js.off,
             configs.boot.valid

      config = require '../../../lib/utils/config'

      should.exist config.minify
      config.minify.js.should.be.false

    it 'minify.js may be turned off', ->
      write_config configs.input.valid,
             configs.output.js.valid,
             configs.output.css.valid,
             configs.alias.valid,
             configs.server.valid,
             configs.minify.css.off,
             configs.boot.valid

      config = require '../../../lib/utils/config'
      
      should.exist config.minify
      config.minify.css.should.be.false


  describe '[option:config-file]', ->
    it 'error should be shown when informed config file does not exist', (done)->

      out = 0
      config_path = path.join base, 'not-existent.yml'
      err_msg = 'error Config file not found ~> ' + config_path

      global.cli_options['config-file'] = 'not-existent.yml'
      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      require '../../../lib/utils/config'

    it 'error should be shown when informed config file is a directory', (done)->

      out = 0
      config_path = path.join base, 'vendors'
      err_msg = 'error Config file\'s path is a directory  ~> ' + config_path

      global.cli_options['config-file'] = 'vendors'
      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      require '../../../lib/utils/config'

  describe '[option:base]', ->
    it 'error should be shown when informed base dir does not exist', (done)->
      out = 0
      error_msgs = [
        'error Dir informed with [--base] option doesn\'t exist ~> non/existent/folder'
        'error Config file not found ~> '
      ]

      global.cli_options.base = 'non/existent/folder'
      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal error_msgs.shift()
        done() unless error_msgs.length

      require '../../../lib/utils/config'