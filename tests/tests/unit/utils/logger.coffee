path = require 'path'
should = require('chai').should()

require 'colors'

describe '[unit][utils] log', ->

  before -> global.__nocolor = true
  after -> global.__nocolor = null && delete global.__nocolor

  afterEach ->
    global.__stdout = global.__stderr = null
    delete global.__stdout
    delete global.__stderr

  it 'error', (done)->
    msgs = [
      'error Hello world'
      'error Hello world 1'
      'error Hello world 1 2'
    ]

    global.__stderr = (data)->
      data.should.equal msgs.shift()
      done() unless msgs.length

    {error} = require('../../../../lib/utils/logger')()
    error 'Hello world'
    error 'Hello world', 1
    error 'Hello world', 1, 2
  
  it 'error with colors', (done)->
    msgs = [
      "#{'error'.bold.red} #{'Hello world'.grey}"
      "#{'error'.bold.red} #{'Hello world'.grey} 1"
      "#{'error'.bold.red} #{'Hello world'.grey} 1 2"
    ]

    global.__stderr = (data)->
      data.should.equal msgs.shift()
      done() unless msgs.length

    global.__nocolor = false

    {error} = require('../../../../lib/utils/logger')()
    error 'Hello world'
    error 'Hello world', 1
    error 'Hello world', 1, 2

    global.__nocolor = true

  it 'warn', (done)->
    msgs = [
      'warn Hello world'
      'warn Hello world 1'
      'warn Hello world 1 2'
    ]

    global.__stderr = (data)->
      data.should.equal msgs.shift()
      done() unless msgs.length
    
    {warn} = require('../../../../lib/utils/logger')()
    warn 'Hello world'
    warn 'Hello world', 1
    warn 'Hello world', 1, 2  

  it 'warn with colors', (done)->
    msgs = [
      "#{'warn'.bold.yellow} #{'Hello world'.grey}"
      "#{'warn'.bold.yellow} #{'Hello world'.grey} 1"
      "#{'warn'.bold.yellow} #{'Hello world'.grey} 1 2"
    ]

    global.__stderr = (data)->
      data.should.equal msgs.shift()
      done() unless msgs.length

    global.__nocolor = false

    delete global.__nocolor
    {warn} = require('../../../../lib/utils/logger')()
    warn 'Hello world'
    warn 'Hello world', 1
    warn 'Hello world', 1, 2

    global.__nocolor = true

  it 'info', (done)->
    msgs = [
      'info Hello world'
      'info Hello world 1'
      'info Hello world 1 2'
    ]

    global.__stdout = (data)->
      data.should.equal msgs.shift()
      done() unless msgs.length

    {info} = require('../../../../lib/utils/logger')()
    info 'Hello world'
    info 'Hello world', 1
    info 'Hello world', 1, 2

  it 'log', (done)->
    msgs = [
      'Hello world'
      'Hello world 1'
      'Hello world 1 2'
    ]

    global.__stdout = (data)->
      data.should.equal msgs.shift()
      done() unless msgs.length

    {log} = require('../../../../lib/utils/logger')()
    log 'Hello world'
    log 'Hello world', 1
    log 'Hello world', 1, 2

  it 'debug', (done)->
    msgs = [
      'tests/log debug Hello world'
      'tests/log debug Hello world 1'
      'tests/log debug Hello world 1 2'
      'debug Hello world'
      'debug Hello world 1'
      'debug Hello world 1 2'
    ]

    global.__stdout = (data)->
      data.should.equal msgs.shift()
      done() unless msgs.length

    {debug} = require('../../../../lib/utils/logger')('tests/log')
    debug 'Hello world'
    debug 'Hello world', 1
    debug 'Hello world', 1, 2

    {debug} = require('../../../../lib/utils/logger')()
    debug 'Hello world'
    debug 'Hello world', 1
    debug 'Hello world', 1, 2

  it 'file:created', (done)->
    global.__stdout = (data)->
      data.should.equal '+ a.coffee'
      done()

    file_created = require('../../../../lib/utils/logger')().file.created
    file_created 'a.coffee'

  it 'file:changed', (done)->
    global.__stdout = (data)->
      data.should.equal '• a.coffee'
      done()

    file_changed = require('../../../../lib/utils/logger')().file.changed
    file_changed 'a.coffee'

  it 'file:deleted', (done)->
    global.__stdout = (data)->
      data.should.equal '- a.coffee'
      done()

    file_deleted = require('../../../../lib/utils/logger')().file.deleted
    file_deleted 'a.coffee'

  it 'file:compiled', (done)->
    global.__stdout = (data)->
      data.should.equal '✓ a.coffee'
      done()
    file_compiled = require('../../../../lib/utils/logger')().file.compiled
    file_compiled 'a.coffee'


  it 'should default to stdout and stderr when no hook is set', (done)->
    backup = stdout: process.stdout.write, stderr: process.stderr.write

    process.stdout.write = (data)->
      process.stdout.write = backup.stdout
      data.stripColors.should.equal 'debug Hello world\n'

    process.stderr.write = (data)->
      process.stderr.write = backup.stderr
      data.stripColors.should.equal 'error Hello world\n'
      backup.stdout = backup.stderr = null
      delete backup.stdout
      delete backup.stderr
      done()

    {error} = require('../../../../lib/utils/logger')()
    {debug} = require('../../../../lib/utils/logger')()

    debug 'Hello world'
    error 'Hello world'