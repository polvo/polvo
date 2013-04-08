setup

  # ============================================================================
  # server setup
  server:
    root: 'public'
    port: 3000

  # ============================================================================
  # source folders
  sources: ['src']

  # excluded folders
  exclude: []

  # included folders
  include: []


  # ============================================================================
  # destination dir for everything
  destination: 'public'

  # ============================================================================
  # module wrappers
  # wrappers:
  #   javascript: 'amd' # templates will follow
  #   styles: 'amd'

  # ============================================================================
  # vendors
  # vendors:

  #   javascript:
  #     jquery       : 'vendors/jquery.js'
  #     vendor_a     : 'vendors/vendor_a.js'
  #     vendor_b     : 'vendors/vendor_b.js'
  #     mocha        : 'vendors/mocha.js'
  #     chai         : 'vendors/chai.js'

  #     # vendors incompatible with the current module wrapper - AMD in this case
  #     incompatible : ['jquery', 'mocha', 'vendor_a', 'vendor_b']

  #   # css:
  #   #   'xyz':  'bla'

  # # ============================================================================
  # # optimization settings
  # optimization:
  #     layers:
  #       'main': ['boot']
  #       'users': ['app/controllers/users']