path = require 'path'

fs = require 'fs'
path = require 'path'

fsu = require 'fs-util'

{log,debug,warn,error} = require '../../../utils/log-util'

module.exports = class Vendors

  constructor:( @toaster, @cli, @config )->

  # merge all vendors into one and return as string
  merge_to_str:->

    buffer = []
    for vname, vpath of @config.browser.vendors
      buffer.push (fs.readFileSync vpath, 'utf-8')

    buffer.join '\n'

  # copy vendors to release folder
  copy_to_release:( all = true, specific = null, log_time = true )->

    return unless @config.browser.vendors?

    for vname, vurl of @config.browser.vendors
      unless /^http/m.test vurl

        continue if all is false and vurl isnt specific

        release_path = path.join @config.release_dir, "#{vname}.js"
        fsu.cp vurl, release_path

        from = vurl.replace @toaster.basepath, ''
        to = release_path.replace @toaster.basepath, ''

        from = from.substr 1 if from[0] is path.sep
        to = to.substr 1 if to[0] is path.sep

        # date for CLI notifications
        now = ("#{new Date}".match /[0-9]{2}\:[0-9]{2}\:[0-9]{2}/)[0]

        msg = if log_time then "[#{now}] " else ""
        msg += "#{'✓ Vendor copied: '.bold}#{from} -> #{to}"

        log msg.green