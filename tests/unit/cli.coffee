should = require('chai').should()

inject = (opts)->
  global.cli_options = opts

describe '[cli]', ->

  after ->
    global.cli_options = null
    delete global.cli_options

  describe '[options injection]', ->
    it 'single line options', ->
      inject w: true
      {argv} = require '../../lib/cli'
      argv.watch.should.be.true
      argv.w.should.be.true

    it 'multi line options', ->
      inject watch: true
      {argv} = require '../../lib/cli'
      argv.watch.should.be.true
      argv.w.should.be.true

    it 'option watch', ->
      inject watch: true
      {argv} = require '../../lib/cli'
      argv.watch.should.be.true
      argv.w.should.be.true

    it 'option compile', ->
      inject compile: true
      {argv} = require '../../lib/cli'
      argv.compile.should.be.true
      argv.c.should.be.true

    it 'option release', ->
      inject release: true
      {argv} = require '../../lib/cli'
      argv.release.should.be.true
      argv.r.should.be.true

    it 'option server', ->
      inject server: true
      {argv} = require '../../lib/cli'
      argv.server.should.be.true
      argv.s.should.be.true

    it 'option config-file', ->
      inject 'config-file': 'sample.yml'
      {argv} = require '../../lib/cli'
      argv['config-file'].should.equal 'sample.yml'
      argv.f.should.equal 'sample.yml'

  describe '[help]', ->
    it 'help should show the help text', ->
      cli = require '../../lib/cli'
      help = cli.help()
      help.should.be.string

    it 'cli_options should not be cached between executions', ->
      inject()
      {argv} = require '../../lib/cli'
      should.not.exist argv['config-file']
      should.not.exist argv.f
