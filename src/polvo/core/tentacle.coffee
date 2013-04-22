# requirements
fs = require 'fs'
fsu = require 'fs-util'
path = require 'path'
cs = require "coffee-script"
cp = require "child_process"
connect = require 'connect'
util = require 'util'
io = require 'socket.io'

# utils
FnUtil = require './../utils/fn-util'
ArrayUtil = require './../utils/array-util'
StringUtil = require './../utils/string-util'
MinifyUtil = require './../utils/minify-util'

Tree = require './tree'
Optimizer = require './optimizer'

{log,debug,warn,error} = require './../utils/log-util'


module.exports = class Tentacle

  socket: null
  trees: null
  optimizer: null

  conn: null
  watchers: null


  constructor:(@polvo, @cli, @config)->
    # initialize
    @init() if @cli.argv.c or @cli.argv.w or @cli.argv.r

    # starts watching if -w is given
    @watch() if @cli.argv.w

    # starts serving static files
    setTimeout (=> @serve()), 1 if @cli.argv.s

  init:()->
    @optimizer = new Optimizer @polvo, @cli, @config, @
    @trees = []
    # for src of @config.sources
    @trees.push (new Tree @polvo, @cli, @config, @)

  serve:->
    root = @config.server.root
    port = @config.server.port
    index = path.join root, 'index.html'

    # simple static server with 'connect'
    @conn = connect()
              .use( connect.static root )
              .use( (req, res)->
                if ~(req.url.indexOf '.')
                  res.statusCode = 404
                  res.end 'File not found: ' + req.url
                else
                  res.end (fs.readFileSync index, 'utf-8')
              ).listen port

    # plugging socket io (only for development mode - excludes -r option)
    unless @cli.argv.r
      @socket = io.listen @conn
      @socket.set 'log level', 1

    address = 'http://localhost:' + port
    log 'Server running at ' + address.green
  
  notify_socket:( file )->
    return unless @socket?
    file_type = file.type
    file_id = file.id
    @socket.sockets.emit 'refresh', {file_type, file_id}

  clear_destination:->
    # clear release folder
    fsu.rm_rf @config.destination if fs.existsSync @config.destination
    fsu.mkdir_p @config.destination

  compile:->
    do @clear_destination
    for tree in @trees
      do tree.compile_files_to_disk

    do @optimizer.copy_vendors_to_release
    do @optimizer.write_amd_loader

  watch:->
    do tree.watch for tree in @trees

  optimize:->
    do @clear_destination
    do @optimizer.optimize

  get_all_files:->
    buffer = []
    for tree in @trees
      buffer = buffer.concat tree.files
    buffer

  reset:()->
    # close all builder's watchers
    @conn.close() if @conn?
    for tree in @trees
      do tree.close_watchers