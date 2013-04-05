path = require 'path'
fs = require 'fs'
fsu = require 'fs-util'

{log,debug,warn,error} = require '../../utils/log-util'

module.exports = class Config

  cs: null

  constructor:( @config, @basepath )-> 

    return unless do @validate_coffeescript

    @cs = config.coffeescript

    # global properties
    return unless do @validate_dirs
    return unless do @validate_exclude
    return unless do @validate_bare
    return unless do @validate_output_dir

    # project nature
    return unless do @validate_project_nature

    if @cs.browser?

      # glogal properties for browser
      return unless do @validate_browser_module_system
      return unless do @validate_browser_main_module
      return unless do @validate_browser_base_url
      return unless do @validate_browser_output_file
      return unless do @validate_browser_vendors
      return unless do @validate_browser_incompatible_vendors

      # optimization
      return unless do @validate_browser_optimize

    else if @cs.desktop?
      # implement
      null

  # ----------------------------------------------------------------------------
  # coffeescript (mandatory)
  validate_coffeescript:->
    unless @config.coffeescript?
      msg = "Config for `coffeescript` not informed, check your config file."
      return error msg
    return yes



  # ----------------------------------------------------------------------------
  # dirs (mandatory)
  validate_dirs:->

    if @cs.dirs is null or @cs.dirs.length is 0
      msg = 'You need to inform at least one dir to `coffeescript.dirs`'
      msg += ', checkyour config file.'
      return error msg

    # expand and validates and all dir paths
    for dir, i in @cs.dirs

      # expanding absolute path
      if dir.indexOf( @basepath ) < 0
        dir = path.join @basepath, dir

      # if folder exists
      if fs.existsSync dir
        @cs.dirs[i] = dir

      # otherwise if folder is not found
      else
        msg = "Informed dir doesn't exist:\n\t#{dir.yellow}"
        msg += '\nCheck your config file.'
        return error msg

    return yes

  # ----------------------------------------------------------------------------
  # exclude (optional)
  validate_exclude:->
    @cs.exclude ?= []
    return yes

  # ----------------------------------------------------------------------------
  # bare (optional)
  validate_bare:->
    @cs.bare ?= true
    return yes

  # ----------------------------------------------------------------------------
  # output_dir (mandatory)
  validate_output_dir:->

    # check if prop is set
    if @cs.output_dir is null
      msg = 'You need to inform your `output_dir`, check your config file.'
      return error msg
    
    # expand absolute path as needed
    if (@cs.output_dir.indexOf @basepath) < 0
      @cs.output_dir = path.join @basepath, @cs.output_dir

    # if folder existence
    unless fs.existsSync @cs.output_dir
      fsu.mkdir_p @cs.output_dir
      msg = "Config `output_dir` doesn't exist, creating one:"
      msg += "\n\t#{@cs.output_dir.cyan}"
      warn msg

    return yes



  # ----------------------------------------------------------------------------
  # nature conflicts (desktop vs browser)
  validate_project_nature:->
    if @cs.desktop? and @cs.browser?
      msg = 'Cannot use two natures in the same project. Choose between '
      msg += '`browser` or `desktop`, check your config file.'
      return error msg
    return yes


  # ----------------------------------------------------------------------------
  # module system (mandatory)
  validate_browser_module_system:->
    ms = @cs.browser.module_system
    unless (ms is 'amd' or ms is 'amd' or ms is 'none')
      msg = 'Invalid value for property `coffeescript.browser.module_system`.\n'
      msg += 'Check your config file, valid options are `amd`, `cjs` or `none`.'
      return error msg
    return yes

  # ----------------------------------------------------------------------------
  # main_module (optional)
  validate_browser_main_module:->
    unless @cs.browser.main_module?
      msg = 'Property `coffeescript.browser.main_module` not informed.\n'
      msg += 'Check your config file.'
      return error msg
    return yes

  # ----------------------------------------------------------------------------
  # base_url (optional)
  validate_browser_base_url:->
    if @cs.browser.base_url?
      if @cs.browser.base_url.slice -1 isnt '/'
        @cs.browser.base_url += '/'
    else
        @cs.browser.base_url = ''

    return yes

  # ----------------------------------------------------------------------------
  # output_file (mandatory)
  validate_browser_output_file:->
    unless @cs.browser.output_file?
      msg = 'Property `coffeescript.browser.output_file` not informed.\n'
      msg += 'Check your config file.'
      return error msg
    return yes



  # ----------------------------------------------------------------------------
  # vendors (optional)
  validate_browser_vendors:->
    @cs.browser.vendors ?= []
    for vname, vpath of @cs.browser.vendors

      # skip cdn vendors
      continue if /^http/m.test vpath

      # expands absolute path as needed
      if (vpath.indexOf @basepath) < 0
        vpath = path.join @basepath, vpath

      # if file is a symbolic link, expands it's realpath
      if (fs.lstatSync vpath).isSymbolicLink()
        vpath = path.join (path.dirname vpath), (fs.readlinkSync vpath)

      # check file existence
      unless fs.existsSync vpath
        # error "Local vendor not found. #{dir}\nCheck your config."
        msg = 'Local vendor not found:'
        msg += '\n\t' + vpath
        msg += '\nCheck your config file.'
        return error msg


      @cs.browser.vendors[vname] = vpath
    
    return yes

  # ----------------------------------------------------------------------------
  # incompatible_vendors (optional)
  validate_browser_incompatible_vendors:->
    @cs.browser.incompatible_vendors ?= []
    for vendor in @cs.browser.incompatible_vendors
      unless (vendor of @cs.browser.vendors)
        msg = "Incompatible vendor '#{vendor}' doesn't exist in `vendors` "
        msg += "property. Check your config file."
        return error msg
    return yes



  # ----------------------------------------------------------------------------
  # optimize (optional)
  validate_browser_optimize:->
    if @cs.browser.optimize?

      @cs.browser.optimize.minify ?= true

      if (@cs.browser.optimize.merge? or @cs.browser.optimize.layers?) is false
        msg = 'Choose a optimization method, options are `merge` or `layers`.'
        msg += '\nCheck your config file.'
        return error msg

      else if (@cs.browser.optimize.merge? and @cs.browser.optimize.layers?)
        msg = 'Only one optimization method is allowed, choose `layers` '
        msg += 'or `merge`.'
        return error msg
    return yes