cli = require '../../lib/cli'
should = require('chai').should()

describe '[cli]', ->

  describe '[options injection]', ->
    it 'single line options', ->
      argv = cli.argv w: true
      argv.watch.should.be.true
      argv.w.should.be.true

    it 'multi line options', ->
      argv = cli.argv watch: true
      argv.watch.should.be.true
      argv.w.should.be.true

    it 'option watch', ->
      argv = cli.argv watch: true
      argv.watch.should.be.true
      argv.w.should.be.true

    it 'option compile', ->
      argv = cli.argv compile: true
      argv.compile.should.be.true
      argv.c.should.be.true

    it 'option release', ->
      argv = cli.argv release: true
      argv.release.should.be.true
      argv.r.should.be.true

    it 'option sever', ->
      argv = cli.argv server: true
      argv.server.should.be.true
      argv.s.should.be.true

    it 'option config-file', ->
      argv = cli.argv 'config-file': 'sample.yml'
      argv['config-file'].should.equal 'sample.yml'
      argv.f.should.equal 'sample.yml'

    # it 'option stdio', ->
    #   argv = cli.argv stdio: true
    #   argv.stdio.should.be.true

    it 'option base', ->
      argv = cli.argv base: '/some/dir'
      argv.base.should.equal '/some/dir'

  describe '[help]', ->
    it 'help should show the help text', ->
      help = cli.help()
      help.should.be.string

  describe '[global_params]', ->
    it 'global_options should be caught automatically when setted', ->
      global.global_options = f: 'sample.yml'
      argv = cli.argv()
      argv['config-file'].should.equal 'sample.yml'
      argv.f.should.equal 'sample.yml'
      global.global_options = null
      delete global.global_options
   
    it 'global_options should not be cached between executions', ->
      argv = cli.argv()
      should.not.exist argv['config-file']
      should.not.exist argv.f