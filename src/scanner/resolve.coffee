path = require 'path'
fs = require 'fs'

config = require('../utils/config').parse()
dirs = require '../utils/dirs'
plugins = require '../utils/plugins'
logger = require('../utils/logger')('scanner/resolve')


{error, warn, info, debug, log} = logger


exts = []
for plugin in plugins
  exts = exts.concat plugin.exts if plugin.output is 'js'

# resolve the given id relatively to the current filepath
# ------------------------------------------------------------------------------
resolve = module.exports = (filepath, id)->

  # removes js extension to normalize id
  id = id.replace /\.js$/m, ''

  # try to resolve its real path
  file = resolve_id filepath, id

  dirpath = path.dirname filepath

  # return normalized path if file is found
  return (path.resolve file) if file?

  # otherwise show error
  caller = path.relative dirs.pwd(), filepath
  error "Module '#{id}' not found for '#{caller}'"
  return null


# Resolves the required id/path
# ------------------------------------------------------------------------------
resolve_id = (filepath, id)->

  # for globals, always go on for module
  if id[0] isnt '.'
    return resolve_module filepath, id

  # breaks id path nodes (if there's some)
  segs = [].concat (id.split '/')

  # filter dirname from filepath, to start the search
  idpath = path.dirname filepath

  # loop them mounting the full path relatively to current
  while segs.length
    seg = do segs.shift
    idpath = path.resolve idpath, seg

  # file.js
  return file if (file = resolve_file idpath)

  # module
  return file if (file = resolve_module filepath, id)

  # dir/index.js
  return file if (file = resolve_index idpath)


# tries to get the file by its name
# ------------------------------------------------------------------------------
resolve_file = ( filepath )->
  for ext in exts
    tmp =  filepath
    tmp = tmp.replace ext, ''
    tmp += ext
    return tmp if fs.existsSync tmp
  return null


# tries to get the index file inside a directory
# ------------------------------------------------------------------------------
resolve_index = ( dirpath )->
  filepath = path.join dirpath, 'index'
  for ext in exts
    tmp =  filepath
    tmp += ext
    return tmp if fs.existsSync tmp
  return null


# ------------------------------------------------------------------------------
resolve_module = (filepath, id)->
  
  if config.virtual?
    for map, location of config.virtual
      if id.indexOf(map) is 0
        nmods = path.join dirs.pwd(), location
        id = id.match(/\/(.+)/)[0]
        break

  unless nmods?
    nmods = closest_node_modules filepath

  # if no node_modules is found, return null
  return null if not nmods

  # trying to reach the `main` entry in package.json (if there's one)
  json = path.join nmods, id, 'package.json'
  if json and fs.existsSync json

    # tries to get the main entry in package.json
    main = (require json).main
    if main?

      # trying to get it as is
      main = path.join (path.dirname json), main
      if (file = resolve_file main)?
        return file 

      # or as a folder with an index file inside
      dir = path.join (path.dirname json), dir
      return file if (file = resolve_index main)?

    # if there's no main entry, tries to get the index file
    return file if (file = resolve_index file)?

    # keep searching on parent node_module's folders
    if filepath is not '/'
      resolve_module path.join(filepath, '..'), di
  
  # if there's no json, move on with other searches
  idpath = (path.join nmods, id)

  # tries to get file as is
  return file if (file = resolve_file idpath)?

  # and finally as index
  return file if (file = resolve_index idpath)?

  # keep searching on parent node_module's folders
  if filepath isnt '/'
    resolve_module path.join(filepath, '..'), id


# searches for the closest node_modules folder in the parent dirs
# ------------------------------------------------------------------------------
closest_node_modules = (filepath)->
  if (path.extname filepath) isnt '' 
    if not fs.lstatSync(filepath).isDirectory()
      tmp = path.dirname filepath
  else
    tmp = filepath

  while tmp isnt '/'
    nmods = path.join tmp, 'node_modules'
    if fs.existsSync nmods
      return nmods
    else
      tmp = path.join tmp, '..'

  return null