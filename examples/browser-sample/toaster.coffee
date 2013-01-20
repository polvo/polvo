# a single build's config
#  ~> many can be specified repeating everything bellow this line
toast

  name: 'browser-sample'

  # src folders (relative to this!)
  dirs:[
    'src'
  ]

  # excluded items (default=[])
  exclude: []

  # removes coffee safety wrapper (default=true - duplicates the AMD wrapper)
  bare: true

  # minifies release files (default=true)
  minify: true

  # release folder
  release_dir: 'www/js'

  # base url to reach your release folder through htto
  base_url: 'js'

  # optimization configs (when specified, means toaster's loader will be used)
  # the resulting will probably not be usefull with another AMD loader
  optimize:

    # vendors to consider (can be local or remote)
    vendors:
      'jquery': 'https://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js'
      '_': 'src/vendors/_.js'

    # TODO: draft
    # 
    # each layer wil hold all the definitions needed (all levels) in order to
    # work. if layers share dpendencies, they will not repeated from the first
    # to the last.
    # 
    # main:
    #  ~> will become www/js/main.s
    # 
    # progressive:
    #   ~> will become www/js/progressive.s
    #   ~> wont duplicate modules already included in `main`.
    # 
    # triphop:
    #   ~> will become www/js/triphop.s
    #   ~> wont duplicate modules already included in `main` and `progressive`.
    # 
    # important to say that if `progressive` layers have some shared dependency
    # with the `main` layer, it'll not be included twice across layers.
    # 
    # so try to mount your layers orderly as your app as usued. anyhow, nothing
    # will demage your application, because 
    # 
    # anyway, if you load some progressive/* module and 
    layers:
      'main': ['app/app']
      'progressive': ['genres/progressive/']
      'triphop': ['genres/triphop/*']