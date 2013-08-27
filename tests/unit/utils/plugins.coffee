path = require 'path'
should = require('chai').should()

global.global_options = base: path.join __dirname, '..', '..', 'mocks', 'basic'
plugins = require '../../../lib/utils/plugins'

describe '[plugins]', ->
  it 'the full list must to be collected ', ->
    plugins.length.should.equal 6
    global.global_options = null
    delete global.global_options