require('source-map-support').install()

fsu = require 'fs-util'

{log,debug,warn,error} = require '../../utils/log-util'

path = require 'path'
fs = require 'fs'
util = require 'util'

module.exports = class Optimizer
  constructor:( @toaster, @cli, @config, @tree )->
    console.log 'Optimizer Toaster'
    console.log @toaster


  optimize_for_development:->
    if @config.browser?
      @copy_vendors_to_release()

      if @config.browser.amd
        @write_loader()

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


  # copy vendors to release folder
  copy_vendors_to_release:( all = true, specific = null, log_time = true )->

    return unless @config.browser.vendors?

    for vname, vurl of @config.browser.vendors
      unless /^http/m.test vurl

        continue if all is false and vurl isnt specific

        release_path = path.join @config.release_dir, "#{vname}.js"
        fsu.cp vurl, release_path

        from = vurl.replace @toaster.basepath, ''
        to = release_path.replace @toaster.basepath, ''

        from = from.substr 1 if from[0] is path.sep
        to = to.substr 1 if to[0] is path.sep

        # date for CLI notifications
        now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

        msg = if log_time then "[#{now}] " else ""
        msg += "#{'✓ Vendor copied: '.bold}#{from} -> #{to}"

        log msg.green

        return if all is false and specific?



  close_watchers:->
    console.log 'close watchers'
    watcher.close() for watcher in @watchers
    console.log 'CLOSED!'



  _on_fs_change:(is_vendor, dir, event, file)=>

      # skip all folder creation
      return if file.type is "dir" and event == "create"
      
      # expand file location and type
      {location, type} = file

      # check if it should be be ignored..
      include = true
      for item in @config.exclude
        include &= not (new RegExp( item ).test location)

      # and aborts in case it should!
      return unless include

      # titleize the type for use in the log messages bellow
      type = StringUtil.titleize file.type

      # relative filepath
      relative_path = location.replace dir, ''
      relative_path = (relative_path.substr 1) if relative_path[0] is path.sep

      # date for CLI notifications
      now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

      # switch over created, deleted, updated and watching
      switch event

        # when a new file is created
        when "create"

          # cli filepath
          msg = "+ #{type} created".bold
          log "[#{now}] #{msg} #{relative_path}".cyan

          # initiate file and adds it to the array
          @files.push script = new Script @, dir, location
          script.compile_to_disk @config

        # when a file is deleted
        when "delete"

          # removes files from array
          file = ArrayUtil.find @files, 'filepath': relative_path
          return if file is null

          file.item.delete_from_disk()
          @files.splice file.index, 1

          # cli msg
          msg = "- #{type} deleted".bold
          log "[#{now}] #{msg} #{relative_path}".red

        # when a file is updated
        when "change"

          # updates file information
          file = ArrayUtil.find @files, 'filepath': relative_path

          if file is null and is_vendor is false
            warn "Change file is apparently null, it shouldn't happened.\n"+
                "Please report this at the repo issues section."
          else

            # cli msg
            msg = "• #{type} changed".bold
            log "[#{now}] #{msg} #{relative_path}"

            if is_vendor
              @copy_vendors_to_release false, location
            else
              file.item.getinfo()
              file.item.compile_to_disk @config

  _get_amd_loader:->
    rjs_path = path.join @toaster.toaster_base, 'node_modules'
    rjs_path = path.join rjs_path, 'requirejs', 'require.js'
    console.log ">>>>>>>>>>>>>>>>>>>>>>>> " + rjs_path
    fs.readFileSync rjs_path, 'utf-8'