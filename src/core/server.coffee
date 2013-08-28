path = require 'path'
fs = require 'fs'

connect = require 'connect'
io = require 'socket.io'

cli = require '../cli'
dirs = require '../utils/dirs'
config = require('../utils/config').parse()
sourcemaps = require '../utils/sourcemaps'

{error, warn, info, debug, log} = require('../utils/logger')('core/server')

app = null

refresher = null
module.exports = ->
  {root, port} = config.server

  argv = cli.argv()

  index = path.join root, 'index.html'

  # simple static server with 'connect'
  app = connect()
    .use( connect.static root )
    .use( (req, res)->
      if ~(req.url.indexOf '.')
        res.statusCode = 404
        res.end 'File not found: ' + req.url
      else
        res.end fs.readFileSync index, 'utf-8'
    ).listen port

  address = 'http://localhost:' + port
  log "♫  #{address}"

  unless argv.r
    refresher = io.listen 53211, 'log level': 1

  module.exports

module.exports.close = ->
  app?.close()

module.exports.reload = ( type )->
  return unless refresher?
  css_output = path.basename config.output.css
  refresher.sockets.emit 'refresh', {type, css_output}