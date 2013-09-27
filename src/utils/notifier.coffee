fs = require 'fs'
zlib = require 'zlib'

humanize = require 'humanize'

{argv} = require '../cli'
logger = require('../utils/logger')('core/compiler')

{error, warn, info, debug} = logger
log_compiled = logger.file.compiled

module.exports = ( filepath, done )->
  fsize = humanize.filesize fs.statSync(filepath).size

  if not argv.release
    log_compiled "#{filepath} (#{fsize})"
    return done?()

  zlib.gzip fs.readFileSync(filepath, 'utf-8'), (err, gzip)->
    fs.writeFileSync filepath + '.tmp.gzip', gzip
    gsize = humanize.filesize fs.statSync(filepath + '.tmp.gzip').size
    log_compiled "#{filepath} (#{fsize}) (#{gsize} gzipped)"
    fs.unlinkSync filepath + '.tmp.gzip'
    done?()