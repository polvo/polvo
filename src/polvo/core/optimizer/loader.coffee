fs = require 'fs'
path = require 'path'
util = require 'util'

{log,debug,warn,error} = require '../../utils/log-util'

module.exports = class Loader
  constructor:( @polvo, @cli, @config, @tentacle, @optimizer )->

  write_amd_loader:( paths )->

    # increment map with all remote vendors
    paths or= {}
    for name, url of @config.vendors
      paths[name] = url if /^http/m.test url

    # mounting main polvo file, contains the polvo builtin amd loader, 
    # all the necessary configs and a hash map containing the layer location
    # for each module that was merged into it.

    loader = @get_amd_loader()

    if paths?
      paths = (util.inspect paths).replace /\s/g, ''
    else paths = '{}'

    loader += """\n\n
      /*************************************************************************
       * Automatic configuration by Polvo.
      *************************************************************************/

      require.config({
        baseUrl: '#{@config.base_url}',
        paths: #{paths}
      });
      require( ['#{@config.main_module}'] );

      /*************************************************************************
       * Automatic configuration by Polvo.
      *************************************************************************/
    """

    # writing to disk
    release_path = path.join @config.destination, @config.index

    if @config.optimize.minify && @cli.r
      loader = MinifyUtil.min loader

    fs.writeFileSync release_path, loader

  get_amd_loader:->
    rjs_path = path.join @polvo.polvo_base, 'node_modules'
    rjs_path = path.join rjs_path, 'requirejs', 'require.js'
    fs.readFileSync rjs_path, 'utf-8'