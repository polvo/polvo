var path = require('path');

var _ = require('lodash');
var should = require('should');

var polvo = require('../../lib');


describe('[core/env]', function(){

  it('proper configs', function(){

    // setup final configuration to test against
    var config = {
      dev: {
        input: [path.join(__dirname, '../../lib')],
        output: {
          js: path.join(__dirname, 'app.js'),
          css: path.join(__dirname, 'app.css')
        },
        minify: {css: false, js: false},
        server: {port: 3000, root: path.join(__dirname, '.')},
        options: { watch: true, concat: true, server: true, repl: true}
      }
    };

    config.prod = _.cloneDeep(config.dev);
    config.prod.minify = {js: true, css: true};
    config.prod.server.port = 3001;
    
    config.test = _.cloneDeep(config.dev);
    config.test.minify = {js: false, css: false};
    config.test.server.port = 3002;


    // instantiate polvo using current dir as project path
    var app = polvo(__dirname);

    app.env('dev prod')
      .input('../../lib')
      .output({
        js: 'app.js',
        css: 'app.css'
      })
      .server({
        port: 3000,
        root: '.'
      })
      .options({
        repl: true,
        server: true,
        concat: true,
        watch: true
      });

    app.env('prod')
      .minify({js: true, css: true})
      .server({port: 3001})

    app.env('test')
      .inherit('prod')
      .minify({js: false, css: false})
      .server({port: 3002});


    should.exist(app.envs.dev);
    should.exist(app.envs.prod);
    should.exist(app.envs.test);

    app.envs.dev.settings.should.eql(config.dev);
    app.envs.prod.settings.should.eql(config.prod);
    app.envs.test.settings.should.eql(config.test);
  });

  it('cannot inherit, env not found', function(){
    (function(){
      polvo().env('dev').inherit('none');
    }).should.throw(/Cannot inherit from/);
  });

  it('no input set', function(){
    (function(){
      polvo().env('dev').input();
    }).should.throw(/Input can't be blank/);
  });

  it('input path not found', function(){
    (function(){
      polvo().env('dev').input('none');
    }).should.throw(/^Input path not found/m);
  });

  it('no output set', function(){
    (function(){
      polvo().env('dev').output();
    }).should.throw(/^Output not set/m);
  });

  it('css output not found', function(){
    (function(){
      polvo().env('dev').output({css: './none/app.css'});
    }).should.throw(/^Output folder for css not found/m);
  });

  it('js output not found', function(){
    (function(){
      polvo().env('dev').output({css: './none/app.js'});
    }).should.throw(/^Output folder for css not found/m);
  });

  it('server root not found', function(){
    (function(){
      polvo().env('dev').server({root: 'none'});
    }).should.throw(/^Server root folder not found/m);
  });

});