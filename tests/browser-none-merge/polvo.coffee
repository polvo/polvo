setup

  languages:
    javascript: 'coffeescript'

  server:
    root: 'www'
    port: 3000

  coffeescript:

    dirs: ['src']
    exclude: []
    bare: true
    output_dir: 'www/js'

    browser:

      module_system: 'none'
      main_module: 'boot'

      base_url: 'js'
      output_file: 'app.js'

      vendors:
        'jquery': 'vendors/jquery.js'
        'vendor_a': 'vendors/vendor_a.js'
        'vendor_b': 'vendors/vendor_b.js'
        'mocha': 'vendors/mocha.js'
        'chai': 'vendors/chai.js'

      optimize:
        minify: false
        merge: 'app.js'