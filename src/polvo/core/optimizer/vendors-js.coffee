path = require 'path'

fs = require 'fs'
path = require 'path'

fsu = require 'fs-util'

{log,debug,warn,error} = require '../../utils/log-util'


module.exports = class VendorsJS

  constructor:( @polvo, @cli, @config, @tentacle, @optimizer )->

  # merge all vendors into one and return as string
  merge_to_str:->
    buffer = []
    for vname, vpath of @config.vendors.javascript
      continue if vname is 'incompatible'

      contents = fs.readFileSync vpath, 'utf-8'

      # if vendor is an AMD module, makes sure the define call is not anonymous
      unless (vname in @config.vendors.javascript.incompatible)
        match_define_calls = /(define[\s]*\()[\s]*(function)/g
        contents = contents.replace match_define_calls, "$1'#{vname}',$2"

      buffer.push contents

    buffer.join '\n'

  # copy vendors to release folder
  copy_to_release:( all = true, specific = null, log_time = true )->
    paths = {}

    for vname, vurl of @config.vendors.javascript
      continue if (/^http/m.test vurl) or (vname is 'incompatible')

      continue if all is false and vurl isnt specific

      release_dir = path.join @config.destination, 'vendors'
      release_path = path.join release_dir, "#{vname}.js"
      paths[vname] = "vendors/#{vname}"

      fsu.mkdir_p release_dir unless fs.existsSync release_dir
      fsu.cp vurl, release_path

      from = vurl.replace @polvo.basepath, ''
      to = release_path.replace @polvo.basepath, ''

      from = from.substr 1 if from[0] is path.sep
      to = to.substr 1 if to[0] is path.sep

      log "✓ #{to}".green

    return paths