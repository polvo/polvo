fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

polvo = require '../../../lib/polvo'
basic = path.join __dirname, '..', '..', 'fixtures', 'basic'

describe '[acceptance] watch', ->
  it 'should watch and serve app, reporting 200 and 404 codes', (done)->

    errors = outs = 0
    checkers = [
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /♫  http\:\/\/localhost:8080/
    ]

    server = null

    options = compile:true, server: 'true', base: basic
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        checkers.shift().test(msg).should.be.true
        if checkers.length is 0
          new setTimeout ->
            exec 'curl -I localhost:8080/app.js', (err, stdout, stderr)->
              /HTTP\/1\.1 200 OK/.test(stdout).should.be.true
              exec 'curl -I localhost:8080/fake.js', (err, stdout, stderr)->
                /HTTP\/1\.1 404 Not Found/.test(stdout).should.be.true
                exec 'curl -I localhost:8080/route', (err, stdout, stderr)->
                  /HTTP\/1\.1 200 OK/.test(stdout).should.be.true
                  done()
                  server.close()
                  errors.should.equal 0
          , 500

    polvo = require '../../../lib/polvo'
    server = polvo options, stdio