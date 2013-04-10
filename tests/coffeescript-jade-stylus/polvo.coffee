setup

  # ============================================================================
  # server setup
  server:
    root: 'www'
    port: 3000

  # ============================================================================
  # source folders
  sources: ['src']

  # excluded folders (if informed, all others will be included)
  exclude: []

  # included folders (if informed, all others will be excluded)
  include: []

  # ============================================================================
  # destination dir for everything
  destination: 'www/js'

  # ============================================================================
  # path to readh `js` folder through http starting from `/`
  base_url: 'js'

  # ============================================================================
  # development and release files will have this name (inside destinaton folder)
  index: 'app.js'

  # ============================================================================
  # main module to be loaded
  main_module: 'boot'

  # ============================================================================
  # module wrappers
  wrappers:
    javascript: 'amd' # templates will follow
    style: 'amd'

  # ============================================================================
  vendors:

    javascript:
      jquery       : 'vendors/jquery.js'
      vendor_a     : 'vendors/vendor_a.js'
      vendor_b     : 'vendors/vendor_b.js'
      mocha        : 'vendors/mocha.js'
      chai         : 'vendors/chai.js'

      # vendors incompatible with the current module wrapper - AMD in this case
      incompatible : ['jquery', 'mocha', 'vendor_a', 'vendor_b']

    # css:
    #   'xyz':  'bla'

  # # ============================================================================
  # # optimization settings
  optimize:
    minify: false
    merge: true