fs = require 'fs'
path = require 'path'
exec = require('child_process').exec

polvo = require '../../../lib/polvo'

# fixture basic
fix_path = path.join __dirname, '..', '..', 'fixtures', 'basic'
files_path = 
  app: path.join fix_path, 'src', 'app', 'app.coffee'
  script: path.join fix_path, 'src', 'app', 'temp.coffee'
  unrecognized: path.join fix_path, 'src', 'app', 'unrecognized.ext'
  styl: path.join fix_path, 'src', 'styles', '_header.styl'
  js: path.join fix_path, 'public', 'app.js'
  dir: path.join fix_path, 'src', 'app', 'empty'
  css: path.join fix_path, 'public', 'app.css'
  vendor: path.join fix_path, 'vendors', 'some.vendor.js'
  jade: path.join fix_path, 'src', 'templates', '_header.jade'
  package: path.join fix_path, 'package.json'
  config: path.join fix_path, 'polvo.yml'

fix_config = """
server:
  port: 8080
  root: ./public

input:
  - src

output:
  js: public/app.js
  css: public/app.css

alias:
  mapped: mapped/src

boot: src/app/app
"""

fix_pack = '{"name": "fix"}'


write_config = ->
  fs.writeFileSync files_path.config, fix_config

delete_config = ->
  fs.unlinkSync files_path.config

write_package = ->
  fs.writeFileSync files_path.package, fix_pack

delete_package = ->
  fs.unlinkSync files_path.package



describe '[polvo:heavy]', ->

  it 'should alert about no app\'s `package.json` file during compile', ->
    errors = outs = 0
    checker = /^info app doesn't have a `package.json`/m

    options = compile: true, base: fix_path
    stdio = 
      nocolor: true
      err:(msg)-> errors++
      out:(msg)->
        if outs is 0
          checker.test(msg).should.be.true
          outs++

    write_config()

    compile = polvo options, stdio
    outs.should.equal 1
    errors.should.equal 0

    delete_config()


  it 'should compile app without any surprises', ->
    errors = outs = 0
    checker = /✓ public\/app\.(js|css).+$/m

    options = compile: true, base: fix_path
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    write_config()
    write_package()

    compile = polvo options, stdio
    outs.should.equal 2
    errors.should.equal 0

    delete_config()
    delete_package()

  it 'should compile app using --split without any surprises', ->
    errors = outs = 0
    # checker = /✓ public\/app\.(js|css).+$/m
    checker = ///
      (
        ✓ public/__split__/polvo/tests/fixtures/
        (
          basic/mapped/src/lib.js
          | basic/src/app/app.js
          | basic/src/app/vendor-hold.js
          | basic/src/templates/_header.js
          | basic/src/templates/top.js
          | basic/vendors/another.vendor.js
          | basic/vendors/some.vendor.js
        ).+
      )?
      |(✓ public/app.js)
      |(✓ public/app.css)
    ///

    options = compile: true, base: fix_path, split: true
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checker.test(msg).should.be.true

    write_config()
    write_package()

    compile = polvo options, stdio
    outs.should.equal 9
    errors.should.equal 0

    delete_config()
    delete_package()

  it 'should release app without any surprises', ->
    errors = outs = 0
    checker = /✓ public\/app\.(js|css).+$/m

    options = release: true, base: fix_path
    stdio = 
      out:(msg) -> checker.test(msg).should.be.true
      err:(msg) -> errors++
      nocolor: true

    write_config()
    write_package()

    release = polvo options, stdio
    errors.should.equal 0

    delete_config()
    delete_package()

  it 'should release app using --split without any surprises', (done)->
    errors = outs = 0
    checker = ///
      (
        ✓ public/__split__/polvo/tests/fixtures/
        (
          basic/mapped/src/lib.js
          | basic/src/app/app.js
          | basic/src/app/vendor-hold.js
          | basic/src/templates/_header.js
          | basic/src/templates/top.js
          | basic/vendors/another.vendor.js
          | basic/vendors/some.vendor.js
        ).+
      )?
      |(✓ public/app.js)
      |(✓ public/app.css)
    ///

    options = release: true, base: fix_path, split: true
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        checker.test(msg).should.be.true
        if ++outs is 9
          errors.should.equal 0

          delete_config()
          delete_package()
          done?()

    write_config()
    write_package()

    compile = polvo options, stdio


  it 'should release and serve app without any surprises', (done)->

    errors = outs = 0
    checkers = [
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /♫  http\:\/\/localhost:8080/
    ]

    options = release: true, server: true, base: fix_path
    stdio = 
      nocolor: true
      err:(msg) -> errors++
      out:(msg) ->
        outs++
        checkers.shift().test(msg).should.be.true
        if checkers.length is 0
          new setTimeout ->
            server.close()
            errors.should.equal 0
            outs.should.equal 3
            delete_config()
            delete_package()
            done()
          , 500

    write_config()
    write_package()

    server = polvo options, stdio


  it 'should watch and serve app, reporting 200 and 404 codes', (done)->

    errors = outs = 0
    checkers = [
      /✓ public\/app\.js.+/
      /✓ public\/app\.css.+/
      /♫  http\:\/\/localhost:8080/
    ]

    server = null

    options = compile:true, server: 'true', base: fix_path
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

                  delete_config()
                  delete_package()

                  errors.should.equal 0
          , 500

    write_config()
    write_package()

    polvo = require '../../../lib/polvo'
    server = polvo options, stdio

  describe '[file:operations]', ->


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

      options = watch: true, server: true, base: fix_path
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

            delete_config()
            delete_package()

            done()

      write_config()
      write_package()

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

      options = watch: true, server: true, base: fix_path
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

            delete_config()
            delete_package()

            done()

      write_config()
      write_package()

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

      options = watch: true, server: true, base: fix_path
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

            delete_config()
            delete_package()

            done()

      write_config()
      write_package()

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

      options = watch: true, server: true, base: fix_path
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

            delete_config()
            delete_package()

            done()

      write_config()
      write_package()

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

      options = watch: true, server: true, base: fix_path
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

            delete_config()
            delete_package()

            done()

      write_config()
      write_package()

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

      options = watch: true, server: true, base: fix_path
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

            delete_config()
            delete_package()

            done()

      write_config()
      write_package()

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

      options = watch: true, server: true, base: fix_path
      stdio = 
        nocolor: true
        err:(msg) -> errors++
        out:(msg) ->
          outs++
          checkers.shift().test(msg).should.be.true

      write_config()
      write_package()

      watch_server = polvo options, stdio

      new setTimeout ->
        content = 'Just some useless content'
        fs.writeFileSync files_path.unrecognized, content
      , 1500

      new setTimeout ->
        errors.should.equal 0
        outs.should.equal 3
        
        watch_server.close()

        delete_config()
        delete_package()

        done()
      , 3000