var path = require('path');

var polvo = require('../../lib');

var io = require('socket.io-client');

var socket_url = 'http://localhost:3000';

var webuser_one = {}

describe('[core/socket]', function(){

  it('able to connect', function( done ){

    var app = polvo(__dirname);

    app.env('dev')
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
        repl: false,
        server: true,
        concat: true,
        watch: true
      });


    //shall we have a getter for the socket_url ?
    //socket_url = polvo.get_socket_url()
    webuser_one = io.connect( socket_url )

    webuser_one.on( 'connect', function(data){ done() } );

  });

  it('able to disconnect', function( done ){

    //shall we have a getter for the socket_url ?
    //socket_url = polvo.get_socket_url()
    webuser_one.on( 'disconnect', function(data){ done() } );

    webuser_one.disconnect()

  });

});