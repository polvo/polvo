path = require 'path'
fs = require 'fs'

connect = require 'connect'
config = require '../utils/config'

module.exports = ->
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
        res.end (fs.readFileSync index, 'utf-8')
    ).listen port

  address = 'http://localhost:' + port
  console.log "♫  #{address}"