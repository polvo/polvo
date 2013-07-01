setup
  
  # ----------------------------------------------------------------------------
  # SERVER

  server:
    root: 'www'
    port: 3000

  # ----------------------------------------------------------------------------
  # FOLDERS

  # source folders
  sources: ['src']

  # excluded folders (if informed, all others will be included)
  exclude: []

  # included folders (if informed, all others will be excluded)
  include: []

  # ----------------------------------------------------------------------------
  # OUTPUT
  
  # destination dir for everything
  destination: 'www/js'

  # main file to be included in your html, development and release files will
  # have this name (inside destinaton folder)
  index: 'app.js'

  # ----------------------------------------------------------------------------
  # AMD CONFIGS

  # path to reach the `js` folder through http starting from `/`
  base_url: 'js'

  # main module to be loaded
  main_module: 'boot'

  # ----------------------------------------------------------------------------
  # VENDORS

  vendors:

    javascript:
      jquery       : 'vendors/jquery.js'
      vendor_a     : 'vendors/vendor_a.js'
      vendor_b     : 'vendors/vendor_b.js'
      mocha        : 'vendors/mocha.js'
      chai         : 'vendors/chai.js'

      # vendors that doesn't implements AMD
      incompatible : ['jquery', 'mocha', 'vendor_a', 'vendor_b']

    css:
      'xyz':  'bla'

  # ----------------------------------------------------------------------------
  # OPTIMIZATION

  optimize:
    minify: false
    merge: true