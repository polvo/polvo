polvo = require '../../lib/polvo'
should = require('chai').should()

describe 'when asking for version', ->
  it 'the right version should be shown', ->
    options = version: true
    version = polvo options, (out)->
      v = out[0]
      v.should.equal require('../../package.json').version