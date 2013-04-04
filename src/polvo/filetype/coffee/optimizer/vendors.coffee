path = require 'path'

fs = require 'fs'
path = require 'path'

fsu = require 'fs-util'

{log,debug,warn,error} = require '../../../utils/log-util'


module.exports = class Vendors

  constructor:( @polvo, @cli, @config )->

  # merge all vendors into one and return as string
  merge_to_str:->
    buffer = []
    for vname, vpath of @config.browser.vendors
      contents = fs.readFileSync vpath, 'utf-8'

      # if vendor is an AMD module, makes sure the define call is not anonymous
      unless (vname in @config.browser.incompatible_vendors)
        match_define_calls = /(define[\s]*\()[\s]*(function)/g
        contents = contents.replace match_define_calls, "$1'#{vname}',$2"

      buffer.push contents

    buffer.join '\n'

  # copy vendors to release folder
  copy_to_release:( all = true, specific = null, log_time = true )->

    return unless @config.browser.vendors?

    for vname, vurl of @config.browser.vendors
      continue if /^http/m.test vurl

      continue if all is false and vurl isnt specific

      release_path = path.join @config.output_dir, "#{vname}.js"
      fsu.cp vurl, release_path

      from = vurl.replace @polvo.basepath, ''
      to = release_path.replace @polvo.basepath, ''

      from = from.substr 1 if from[0] is path.sep
      to = to.substr 1 if to[0] is path.sep

      # date for CLI notifications
      now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

      msg = if log_time then "[#{now}] " else ""
      msg += "#{'✓ Vendor copied: '.bold}#{from} -> #{to}"

      log msg.green