fs = require 'fs'
path = require 'path'
util = require 'util'

{log,debug,warn,error} = require '../../../utils/log-util'

module.exports = class Loader
  constructor:( @toaster, @cli, @config )->


  write_loader:( paths )->
    return unless @config.browser.optimize? and @config.browser.amd

    # increment map with all remote vendors
    paths or= {}
    for name, url of @config.vendors
      paths[name] = url if /^http/m.test url

    # mounting main toaster file, contains the toaster builtin amd loader, 
    # all the necessary configs and a hash map containing the layer location
    # for each module that was merged into it.

    loader = @_get_amd_loader()

    if paths?
      paths = (util.inspect paths).replace /\s/g, ''
    else paths = ''

    loader += """\n\n
      /*************************************************************************
       * Automatic configuration by CoffeeToaster.
      *************************************************************************/

      require.config({
        baseUrl: '#{@config.browser.amd.base_url}',
        paths: #{paths}
      });
      require( ['#{@config.browser.amd.main}'] );

      /*************************************************************************
       * Automatic configuration by CoffeeToaster.
      *************************************************************************/
    """

    # writing to disk
    release_path = path.join @config.release_dir, @config.browser.amd.boot

    if @config.browser.optimize.minify && @cli.r
      loader = MinifyUtil.min loader

    fs.writeFileSync release_path, loader

  _get_amd_loader:->
    rjs_path = path.join @toaster.toaster_base, 'node_modules'
    rjs_path = path.join rjs_path, 'requirejs', 'require.js'
    fs.readFileSync rjs_path, 'utf-8'