version = require '../../../../lib/utils/version'
should = require('chai').should()

describe '[unit][utils] version', ->
  it 'the right version should be shown for the -v command', (done)->
    version.should.equal require('../../../../package.json').version
    done()