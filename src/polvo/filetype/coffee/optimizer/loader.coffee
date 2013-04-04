fs = require 'fs'
path = require 'path'
util = require 'util'

{log,debug,warn,error} = require '../../../utils/log-util'

module.exports = class Loader
  constructor:( @polvo, @cli, @config, @tree, @optimizer )->

  write_basic_loader:->
    paths = []

    for name, url of @config.browser.vendors
      paths.push "#{@config.browser.base_url}/#{name}.js"

    @optimizer.reorder @tree.files

    # main = @config.browser.main
    # paths.push "#{@config.browser.base_url}/#{main}.js"

    for file in @tree.files
      filepath = file.filepath.replace @tree.filter, ''

      # continue if filepath is main
      paths.push "#{@config.browser.base_url}#{filepath}.js"

    template = "document.write(\"<scri\" + \"pt src='~SRC'></script>\");\n"

    buffer = ""
    for src in paths
      buffer += template.replace '~SRC', src

    # writing to disk
    release_path = path.join @config.output_dir, @config.browser.output_file
    fs.writeFileSync release_path, buffer



  write_loader:( paths )->
    unless @config.browser.optimize? and @config.browser.module_system is 'amd'
      return

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
    else paths = ''

    loader += """\n\n
      /*************************************************************************
       * Automatic configuration by Polvo.
      *************************************************************************/

      require.config({
        baseUrl: '#{@config.browser.base_url}',
        paths: #{paths}
      });
      require( ['#{@config.browser.main_module}'] );

      /*************************************************************************
       * Automatic configuration by Polvo.
      *************************************************************************/
    """

    # writing to disk
    release_path = path.join @config.output_dir, @config.browser.output_file

    if @config.browser.optimize.minify && @cli.r
      loader = MinifyUtil.min loader

    fs.writeFileSync release_path, loader

  get_amd_loader:->
    rjs_path = path.join @polvo.polvo_base, 'node_modules'
    rjs_path = path.join rjs_path, 'requirejs', 'require.js'
    fs.readFileSync rjs_path, 'utf-8'