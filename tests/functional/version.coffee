polvo = require '../../lib/polvo'
should = require('chai').should()

describe 'version', ->
  it 'the right version should be shown for the -v command', (done)->
    options = version: true
    polvo options, out:(version)->
      version.should.equal require('../../package.json').version
      done()