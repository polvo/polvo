fs = require 'fs'
fsu = require 'fs-util'
path = require 'path'
resolve = require './resolve'
esprima = require 'esprima'

# resolves all `require` calls for the given filepath or dirpath
module.exports = (location, deep)->
# ------------------------------------------------------------------------------
  if do (fs.lstatSync location).isDirectory
    scan_dir deep, location
  else
    scan_files deep, (path.dirname location), [location]


# list all files in a dir, and passe them to the `scan_files` method
# ------------------------------------------------------------------------------
scan_dir = (deep, dirpath)->
  scan_files deep, dirpath, (fsu.find dirpath, /\.js$/m)


# scan all given files, resolves all requirements to the end and
# return an array with them
# ------------------------------------------------------------------------------
scan_files = (deep, dirpath, filepaths)->

  # initialize empty dictionary
  reqs = {}

  # iterate over all filepaths
  for filepath in filepaths

    # mark them as 'viewed'
    reqs[filepath] = 1

    # scan them and move one
    scan_file deep, dirpath, filepath, reqs

  # after all is scanned, initialize a empty buffer
  output = []

  # populate it with all paths (without duplicates)
  for filepath of reqs
    output.push path.relative dirpath, filepath

  # and return it
  output


# scans the given file recursively for `require` calls, resolve everything
# to the end and returned a basic dictionary of paths
# ------------------------------------------------------------------------------
scan_file = (deep, dirpath, filepath, reqs = {})->
  # get file raw contents
  raw = do (fs.readFileSync filepath).toString

  # parse all tokens with esprima
  parsed = esprima.parse raw, tokens: on
  tokens = parsed.tokens

  # loop them, computing and resolving all requirements
  for token, index in tokens
    
    {type, value} = token
    continue unless (type is 'Identifier' and value is 'require')

    {type, value} = tokens[index-1]
    continue unless type is 'Punctuator' and value is '='

    {type} = tokens[index+2]
    continue unless type is 'String'

    req = tokens[index+2].value.replace /'|"/g, ''
    req = resolve dirpath, filepath, req
    index += 3

     # jump to next iteration if item is not found
    continue if req is null

    # add it to the reqs hash
    reqs[req] = 1

    # and scan it as well for other requirements
    if (not /^\.\./m.test path.relative dirpath, req) or deep
      scan_file deep, dirpath, req, reqs