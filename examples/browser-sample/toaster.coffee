# a single build's config
#  ~> many can be specified repeating everything bellow this line
toast

  name: 'browser-sample'

  # src folders (relative to this!)
  dirs:[
    'src'
  ]

  # main module
  main: 'app/app'

  # base url to reach your release folder through htto
  base_url: 'js'

  # release folder
  release_dir: 'www/js'

  # excluded items (default=[])
  exclude: []

  # removes coffee safety wrapper (default=true - duplicates the AMD wrapper)
  bare: true

  # minifies release files (default=true)
  minify: false

  # infos for simple static server (with -s option)
  webroot: 'www'
  port: 3000

  # optimization configs (when specified, means toaster's loader will be used)
  # the resulting will probably not be usefull with another AMD loader
  optimize:

    # vendors to consider (can be local or remote)
    vendors:
      'jquery': 'https://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js'
      '_': 'vendors/_.js'

    # each layer wil hold all the definitions needed (all levels) in order to
    # work. if layers share dpendencies, they will not repeat acros layers.
    layers:
      'main': ['app/app']
      'progressive': ['app/genres/progressive']
      'triphop': ['app/genres/triphop']