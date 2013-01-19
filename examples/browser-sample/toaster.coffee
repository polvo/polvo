# new toast routine
toast

  # src folders
  folders:
    'src':''

  # excluded items (default=[])
  exclude: []

  # removes coffee safaty wrapper (default=true)
  bare: true

  # project nature, can be 'browser' or 'desktop'
  # if browser:
  nature: 'browser':

    base_url: 'js' # default=''
    # minify: true

    # loader: 'toaster':
    #     vendors:[
    #       'jquery': 'http://cdn...'
    #       'name': 'local/path'
    #     ]

    #     optimize:
    #       'main': 'app/app'
    #       'progressive': 'genres/progressive/*'
    #       'triphop': 'genres/triphop/*'

    release: 'www/js/app.js'
  # if desktop:
  # TODO