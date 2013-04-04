#>>
should = null
#<<

require 'mocha'

chai = require 'chai'

should = chai.should()
window.expect = chai.expect
mocha.setup 'bdd'

describe 'Boot (boot.coffee)', ->
    it 'Tests suites must to be loaded and available', ->
        should.exist mocha
        should.exist chai

require ['app/app'], (App)->
  new App()

  ($ document).ready ->
      if window.mochaPhantomJS
          mochaPhantomJS.run()
      else
          mocha.run()