fs = require 'fs'
path = require 'path'
util = require 'util'

{log,debug,warn,error} = require '../../utils/log-util'

module.exports = class Loader

  node_modules: null

  constructor:( @polvo, @cli, @config, @tentacle, @optimizer )->
    @node_modules = path.join @polvo.polvo_base, 'node_modules'


  write_amd_loader:( paths )->

    # increment map with all remote vendors
    paths or= {}
    for name, url of @config.vendors
      paths[name] = url if /^http/m.test url

    # mounting main polvo file, contains the polvo builtin amd loader, 
    # all the necessary configs and a hash map containing the layer location
    # for each module that was merged into it.

    loader = @get_socketio()
    loader += @get_amd_loader()

    if paths?
      paths = (util.inspect paths).replace /\s/g, ''
    else paths = '{}'

    loader += """\n\n
      /*************************************************************************
       * POLVO - Automatic RJS configuration >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      *************************************************************************/

      require.config({
        baseUrl: '#{@config.base_url}',
        paths: #{paths}
      });
      require( ['#{@config.main_module}'] );

      /*************************************************************************
       * <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< POLVO - Automatic configuration
      *************************************************************************/
    """

    # writing to disk
    release_path = path.join @config.destination, @config.index

    if @config.optimize.minify && @cli.r
      loader = MinifyUtil.min loader

    fs.writeFileSync release_path, loader

  get_amd_loader:->

    # fetching compiler's helpers before anything else
    helpers = ''
    for name, compiler of @tentacle.compilers
      if compiler.fetch_helpers
        helpers += '\n\n// ~~ ' + name
        helpers += do compiler.fetch_helpers

    # fetches rjs loader
    rjs_path = path.join @node_modules, 'requirejs', 'require.js'
    rjs = fs.readFileSync rjs_path, 'utf-8'

    # merges and return everything
    initializer = """\n\n
      /*************************************************************************
       * POLVO - Compiler's Helpers >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      *************************************************************************/
      #{helpers}


      /*************************************************************************
       * <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< POLVO - Compiler's Helpers
      *************************************************************************/
      #{rjs}
    """

  get_socketio:->
    initializer = """\n\n
      /*************************************************************************
       * >>>>>>>>>>>>>>>>>>>>>>>>>>>>> POLVO - Socket Initializer for LiveReload
      *************************************************************************/

      var host = window.location.protocol + '//' + window.location.hostname;
      var refresher = io.connect( host, {port: 53211} );
      refresher.on("refresh", function(data)
      {
        var el;

        // refresh approach for javascript and templates
        if(data.file_type == 'javascript' || data.file_type == 'template' )
          return location.reload();
       
        // refresh approach for styles
        if(data.file_type == 'style') {
          el = document.getElementById( data.file_id );
          el.parentNode.removeChild( el );
          require.undef( data.file_id );
          require([data.file_id]);
        }
      });

      /*************************************************************************
       * <<<<<<<<<<<<<<<<<<<<<<<<<<<<< POLVO - Socket Initializer for LiveReload
      *************************************************************************/
    """

    io_path = path.join @node_modules, 'socket.io', 'node_modules'
    io_path = path.join io_path, 'socket.io-client', 'dist', 'socket.io.js'
    
    io = fs.readFileSync io_path, 'utf-8'
    io += "\n\n\n#{initializer}\n\n\n"

  get_compilers_helpers:->
    initializer = ""
