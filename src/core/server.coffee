path = require 'path'
fs = require 'fs'

connect = require 'connect'
io = require 'socket.io'

dirs = require '../utils/dirs'
config = require '../utils/config'
sourcemaps = require '../utils/sourcemaps'

{error, warn, info, debug, log} = require('../utils/logger')('core/server')

Cli = require '../cli'


refresher = null
module.exports = ->
  {argv} = cli = new Cli
  {root, port} = config.server

  index = path.join root, 'index.html'

  # simple static server with 'connect'
  connect()
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
    refresher = io.listen 53211, 'log level': 0

module.exports.reload = ( type )->
  return unless refresher?
  css_output = path.basename config.output.css
  refresher.sockets.emit 'refresh', {type, css_output}