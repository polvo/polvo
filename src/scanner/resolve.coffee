path = require 'path'
fs = require 'fs'

config = require '../utils/config'
dirs = require '../utils/dirs'
plugins = require '../utils/plugins'
logger = require('../utils/logger')('scanner/resolve')


{error, warn, info, debug, log} = logger


exts = []
for plugin in plugins
  exts = exts.concat plugin.exts if plugin.output is 'js'

mod_kinds = 'node_modules components bower_components'.split ' '
mod_manifests = 'package.json component.json bower.json'.split ' '

# resolve the given id relatively to the current filepath
# ------------------------------------------------------------------------------
module.exports = (filepath, id)->

  # removes js extension to normalize id
  id = id.replace /\.js$/m, ''

  # try to resolve its real path
  for kind, index in mod_kinds
    manifest = mod_manifests[index]
    file = resolve_id kind, manifest, filepath, id
    break if file?

  # return normalized path if file is found
  return (path.resolve file) if file?

  # otherwise show error
  caller = path.relative dirs.pwd, filepath
  error "Module '#{id}' not found for '#{caller}'"
  return id


# Resolves the required id/path
# ------------------------------------------------------------------------------
resolve_id = (kind, manifest, filepath, id)->

  # for globals, always go on for module
  if id[0] isnt '.'
    return resolve_module kind, manifest, filepath, id

  # breaks id path nodes (if there's some)
  segs = [].concat (id.split '/')

  # filter dirname from filepath, to start the search
  idpath = path.dirname filepath

  # loop them mounting the full path relatively to current
  while segs.length
    seg = segs.shift()
    idpath = path.resolve idpath, seg

  # file.js
  return file if (file = resolve_file idpath)

  # module
  return file if (file = resolve_module kind, manifest, idpath)

  # mod not found
  return null


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
  # if dirpath?
  filepath = path.join dirpath, 'index'
  for ext in exts
    tmp =  filepath
    tmp += ext
    return tmp if fs.existsSync tmp
  return null


# ------------------------------------------------------------------------------
resolve_module = (kind, manifest, filepath, id = '')->

  if id is ''
    non_recurse = true

  if config.alias?
    for map, location of config.alias
      if id.indexOf(map) is 0
        nmods = path.join dirs.pwd, location
        if ~id.indexOf('/')
          id = id.match(/\/(.+)/)[0]
        else
          id = ''

        break

  unless nmods?
    if id is ''
      nmods = filepath
    else
      nmods = closest_mod_folder kind, filepath

  # if no node_modules is found, return null
  return null if not nmods

  # trying to reach the `main` entry in manifest (if there's one)
  mod = path.join nmods, id
  json = path.join mod, manifest
  if json and fs.existsSync json

    # tries to get the main entry in manifest
    main = (require json).main
    if main?

      # trying to get it as is
      main = path.join (path.dirname json), main
      if (file = resolve_file main)?
        return file 

      # or as a folder with an index file inside
      return file if (file = resolve_index main)?

    else
      # if there's no main entry, tries to get the index file
      if (file = resolve_index mod)?
        return file
  
  # if there's no json, move on with other searches
  idpath = (path.join nmods, id)

  # tries to get file as is
  return file if (file = resolve_file idpath)?

  # and finally as index
  return file if (file = resolve_index idpath)?

  # keep searching on parent node_module's folders
  if filepath isnt '/' and non_recurse isnt true
    resolve_module kind, manifest, path.join(filepath, '..'), id


# searches for the closest node_modules folder in the parent dirs
# ------------------------------------------------------------------------------
closest_mod_folder = (kind, filepath)->
  if (path.extname filepath) isnt '' 
    if not fs.lstatSync(filepath).isDirectory()
      tmp = path.dirname filepath
  else
    tmp = filepath

  while tmp isnt '/'
    nmods = path.join tmp, kind
    if fs.existsSync nmods
      return nmods
    else
      tmp = path.join tmp, '..'

  return null