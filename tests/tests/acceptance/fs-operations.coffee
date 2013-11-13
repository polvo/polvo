fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

polvo = require '../../../lib/polvo'
basic = path.join __dirname, '..', '..', 'fixtures', 'basic'

files_path = 
  app: path.join basic, 'src', 'app', 'app.coffee'
  script: path.join basic, 'src', 'app', 'temp.coffee'
  unrecognized: path.join basic, 'src', 'app', 'unrecognized.ext'
  styl: path.join basic, 'src', 'styles', '_header.styl'
  js: path.join basic, 'public', 'app.js'
  dir: path.join basic, 'src', 'app', 'empty'
  css: path.join basic, 'public', 'app.css'
  vendor: path.join basic, 'vendors', 'some.vendor.js'
  jade: path.join basic, 'src', 'templates', '_header.jade'
  package: path.join basic, 'package.json'
  config: path.join basic, 'polvo.yml'

describe '[acceptance] fs-operations', ->

  it 'should start app, cerate empty dirs, and modify some file', (done)->
    errors = outs = 0
    checkers = [
      # fist compilation
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /\♫  http:\/\/localhost:8080/

      # updating app.coffee
      /\• src\/app\/app.coffee/
      /✓ public\/app\.js/
    ]

    options = watch: true, server: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checkers.shift().test(msg).should.be.true

        if checkers.length is 0
          errors.should.equal 0
          outs.should.equal 5
          watch_server.close()
          done()

    watch_server = polvo options, stdio

    # crating empty folder should do nothing
    new setTimeout (-> fs.mkdirSync files_path.dir), 500

    # deleting empty folder should do nothing
    new setTimeout (-> fs.rmdirSync files_path.dir), 1000

    # editing file
    new setTimeout (-> fs.appendFileSync files_path.app, ' '), 1500


  it 'deleting and creating some file', (done)->
    errors = outs = 0
    checkers = [
      # fist compilation
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /\♫  http:\/\/localhost:8080/

      # removing app.coffee
      /\- src\/app\/app.coffee/
      /✓ public\/app\.js/

      # adding app.coffee
      /\+ src\/app\/app.coffee/
      /✓ public\/app\.js/
    ]

    options = watch: true, server: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checkers.shift().test(msg).should.be.true

        if checkers.length is 0
          errors.should.equal 0
          outs.should.equal 7
          watch_server.close()
          done()

    watch_server = polvo options, stdio

    # deleting file
    backup = fs.readFileSync files_path.app
    new setTimeout (-> fs.unlinkSync files_path.app ), 500

    # creating file
    new setTimeout (-> fs.writeFileSync files_path.app, backup ), 1000


  it 'editing, deleting and creating vendor', (done)->

    errors = outs = 0
    err_checkers = [
      /error Module '..\/..\/vendors\/some.vendor' not found for 'src\/app\/app.coffee'/
      /error Module '..\/..\/vendors\/some.vendor' not found for 'src\/app\/vendor-hold.coffee'/
    ]

    out_checkers = [
      # fist compilation
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /\♫  http:\/\/localhost:8080/

      # updating a deleted vendor
      /\• vendors\/some\.vendor\.js/
      /✓ public\/app\.js/

      # deleting vendor
      /\- vendors\/some\.vendor\.js/
      /✓ public\/app\.js/

      # creating a deleted vendor
      /\+ vendors\/some\.vendor\.js/
      /✓ public\/app\.js/
    ]

    options = watch: true, server: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) ->
        err_checkers.shift().test(msg).should.be.true
        errors++
      out:(msg) ->
        outs++
        out_checkers.shift().test(msg).should.be.true

        if out_checkers.length is 0
          errors.should.equal 2
          outs.should.equal 9
          
          watch_server.close()
          done()

    watch_server = polvo options, stdio

    # editing
    backup = fs.readFileSync files_path.vendor
    new setTimeout (-> fs.appendFileSync files_path.vendor, ' ' ), 500

    # deleting
    new setTimeout (-> fs.unlinkSync files_path.vendor ), 1000

    # crating
    new setTimeout (-> fs.writeFileSync files_path.vendor, backup ), 1500


  it 'editing, deleting and creating template partial', (done)->

    errors = outs = 0
    err_checkers = [
      # alert that _header.jade wasn't found for top.jade 
      /src\/templates\/top\.jade.+no such file or directory.+_header\.jade/
    ]

    out_checkers = [
      # fist compilation
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /\♫  http:\/\/localhost:8080/

      # updating partial
      /\• src\/templates\/_header\.jade/
      /✓ public\/app\.js/

      # deleting partial
      /\- src\/templates\/_header\.jade/
      /✓ public\/app\.js/

      # creating partial
      /\+ src\/templates\/_header\.jade/
      /✓ public\/app\.js/
    ]

    options = watch: true, server: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) ->
        err_checkers.shift().test(msg.replace(/\n/g, '')).should.be.true
        errors++
      out:(msg) ->
        outs++
        out_checkers.shift().test(msg).should.be.true

        if out_checkers.length is 0
          errors.should.equal 1
          outs.should.equal 9
          watch_server.close()
          done()

    watch_server = polvo options, stdio

    # editing
    backup = fs.readFileSync files_path.jade
    new setTimeout (-> fs.appendFileSync files_path.jade, ' ' ), 500

    # deleting
    new setTimeout (-> fs.unlinkSync files_path.jade ), 1000

    # crating
    new setTimeout (-> fs.writeFileSync files_path.jade, backup ), 1500


  it 'editing, deleting and creating style partial', (done)->

    errors = outs = 0
    err_checkers = [
      # alert that _header.jade wasn't found for top.jade 
      /src\/styles\/top\.styl.+failed to locate.+_header\.styl/
    ]

    out_checkers = [
      # fist compilation
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /\♫  http:\/\/localhost:8080/

      # updating partial
      /\• src\/styles\/_header\.styl/
      /✓ public\/app\.css/

      # deleting partial
      /\- src\/styles\/_header\.styl/
      /✓ public\/app\.css/

      # creating partial
      /\+ src\/styles\/_header\.styl/
      /✓ public\/app\.css/
    ]

    options = watch: true, server: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) ->
        err_checkers.shift().test(msg.replace(/\n/g, '')).should.be.true
        errors++
      out:(msg) ->
        outs++
        out_checkers.shift().test(msg).should.be.true

        if out_checkers.length is 0
          errors.should.equal 1
          outs.should.equal 9
          watch_server.close()
          done()

    watch_server = polvo options, stdio

    # editing
    backup = fs.readFileSync files_path.styl
    new setTimeout (-> fs.appendFileSync files_path.styl, ' ' ), 500

    # deleting
    new setTimeout (-> fs.unlinkSync files_path.styl ), 1000

    # crating
    new setTimeout (-> fs.writeFileSync files_path.styl, backup ), 1500

  it 'creating script with inexistent require', (done)->

    errors = outs = 0
    err_checkers = [
      /error Module '.\/non\/existent' not found for 'src\/app\/temp.coffee'/
    ]

    out_checkers = [
      # fist compilation
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /\♫  http:\/\/localhost:8080/

      # creating script
      /\+ src\/app\/temp\.coffee/
      /✓ public\/app\.js/
    ]

    options = watch: true, server: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) ->
        err_checkers.shift().test(msg.replace(/\n/g, '')).should.be.true
        errors++
      out:(msg) ->
        outs++
        out_checkers.shift().test(msg).should.be.true

        if out_checkers.length is 0
          errors.should.equal 1
          outs.should.equal 5
          
          watch_server.close()
          done()

    watch_server = polvo options, stdio

    # creating
    content = 'require "./non/existent"'
    new setTimeout (-> fs.writeFileSync files_path.script, content ), 1500

  it 'creating file with unrecognized ext should do nothing', (done)->

    errors = outs = 0
    checkers = [
      # fist compilation
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /\♫  http:\/\/localhost:8080/
    ]

    options = watch: true, server: true, base: basic
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checkers.shift().test(msg).should.be.true

    watch_server = polvo options, stdio

    new setTimeout ->
      content = 'Just some useless content'
      fs.writeFileSync files_path.unrecognized, content
    , 1500

    new setTimeout ->
      errors.should.equal 0
      outs.should.equal 3
      
      watch_server.close()
      done()
    , 3000