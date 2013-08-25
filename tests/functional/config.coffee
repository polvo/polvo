fs = require 'fs'
path = require 'path'
should = require('chai').should()
config = require '../../lib/utils/config'

base = path.join __dirname, '..', 'mocks', 'basic'
yml = path.join base, 'polvo.yml'

# helper for writing many config files
write_config = (contents...)->
  buffer =  contents.join '\n\n'
  fs.writeFileSync yml, buffer

# config variations templates
configs = 
  server:
    inexistent: 'server:\n  port: 3000\n  root: not/existent/folder'
    valid: 'server:\n  port:3000\n  root: public'

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

  mappings:
    inexistent: 'mappings:\n  mapped: non/existent/folder'
    valid: 'mappings:\n  mapped: mapped/src'


describe   '[config]', ->



  beforeEach ->
    global.global_options = base: base

  afterEach ->
    if fs.existsSync yml
      fs.unlinkSync yml
      delete require.cache[require.resolve yml]

    global.__stdout = global.__stderr = global.global_options = null
    delete global.__stdout
    delete global.__stderr
    delete global.global_options

  after ->



  describe '[config not found]', ->
    it 'error should be shown when config file is not found', (done)->
      out = 0
      reg = /error Config file not found ~>.+\/polvo.yml/m

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        reg.test(data).should.be.true
        done()

      config.parse()



  describe '[option:input]', ->
    it 'error should be shown when option is not set', (done)->
      out = err = 0
      err_msg = 'error You need at least one input dir in config file'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config ''
      config.parse()

    it 'error should be shown when input dir does not exist', (done)->
      out = err = 0
      err_msg = 'error Input dir does not exist ~> non/existent/folder'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.inexistent
      config.parse()



  describe '[option:output]', ->
    it 'error should be shown when option is not set', (done)->
      out = err = 0
      err_msg = 'error You need at least one output in config file'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid
      config.parse()

    it 'error should be shown when js\'s output dir does not exist', (done)->
      out = err = 0
      err_msg = 'error JS\'s output dir does not exist ~> non/existent/folder'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid, configs.output.js.inexistent
      config.parse()

    it 'error should be shown when css\'s output dir does not exist', (done)->
      out = err = 0
      err_msg = 'error CSS\'s output dir does not exist ~> non/existent/folder'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid, configs.output.css.inexistent
      config.parse()



  describe '[option:mappings]', ->

    it 'error should be shown when mapped folder doesn\'t exist', (done)->
      out = err = 0
      err_msg = 'error Mapping dir for \'mapped\' does not exist ~> '
      err_msg += 'non/existent/folder'

      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid,
                   configs.output.js.valid,
                   configs.output.css.valid,
                   configs.mappings.inexistent
      config.parse()



  describe '[option:server]', ->
    it 'error should be shown when server option is not set and -s is in use', (done)->
      out = err = 0
      err_msg = 'error Server\'s config not set in config file'

      global.global_options.server = true
      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid,
                   configs.output.js.valid,
                   configs.output.css.valid,
                   configs.mappings.valid
      config.parse()

    it 'error should be shown when server root dir doest not exist', (done)->
      out = err = 0
      root_dir = path.join base, 'not', 'existent', 'folder'
      err_msg = 'error Server\'s root dir does not exist ~> ' + root_dir 

      global.global_options.server = true
      global.__stdout = (data)-> out++
      global.__stderr = (data)->
        out.should.equal 0
        data.should.equal err_msg
        done()

      write_config configs.input.valid,
                   configs.output.js.valid,
                   configs.output.css.valid,
                   configs.mappings.valid,
                   configs.server.inexistent
      config.parse()
      global.global_options.server = null
      delete global.global_options