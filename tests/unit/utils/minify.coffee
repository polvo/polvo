path = require 'path'
should = require('chai').should()

minify = require '../../../lib/utils/minify'

describe '[minify]', ->

  it 'js should be minified properly', ->
    raw = """
      function require () {
          var one = 1, two = 2, three = 3;
          return {
            a: one,
            b: two,
            c: [
                0, 1, 2, three
            ]
          }
      }
    """
    compressed = 'function require(){var one=1,two=2,three=3;return{a:one,b:two,c:[0,1,2,three]}}'
    minify.js(raw).should.equal compressed

  it 'css should be minified properly', ->
    raw = """
      body {
        font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        font-size: 15px;
      }
    """
    compressed = 'body{font-family:"Helvetica Neue",Helvetica,Arial,sans-serif;font-size:15px}'
    minify.css(raw).should.equal compressed