require('source-map-support').install()

# utils
FnUtil = require './utils/fn-util'
ArrayUtil = require './utils/array-util'
StringUtil = require './utils/string-util'
MinifyUtil = require './utils/minify-util'

{log,debug,warn,error} = require './utils/log-util'


# handlers and optimizers
Tree = require './core/tree'

CoffeeHandler = require './filetype/coffee/handler'
CoffeeOptimizer = require './filetype/coffee/optimizer'

JadeHandler = require './filetype/jade/handler'
JadeOptimizer = require './filetype/jade/optimizer'

StylusHandler = require './filetype/stylus/handler'
StylusOptimizer = require './filetype/stylus/optimizer'

module.exports = class Tentacle

  # requirements
  fs = require 'fs'
  fsu = require 'fs-util'
  path = require 'path'
  cs = require "coffee-script"
  cp = require "child_process"
  conn = require 'connect'
  util = require 'util'

  conn: null
  watchers: null

  filetype: null

  constructor:(@polvo, @cli, @config)->
    # initialize
    @init() if @cli.argv.c or @cli.argv.w or @cli.argv.r

    # starts watching if -w is given
    @watch() if @cli.argv.w

    # starts serving static files
    setTimeout (=> @serve()), 1 if @cli.argv.s

  init:()->
    @filetype = {}

    if @config.languages.javascript is 'coffeescript'
      @filetype.coffeescript = new Tree @polvo,
                              @cli,
                              @config.coffeescript,
                              @,
                              CoffeeHandler,
                              CoffeeOptimizer
                              
    if @config.languages.templates is 'jade'
      jade: new Tree @polvo,
                              @cli,
                              @config.jade,
                              @,
                              JadeHandler,
                              JadeOptimizer

    if @config.languages.styles is 'stylus'
      stylus: new Tree @polvo,
                        @cli,
                        @config.stylus,
                        @,
                        StylusHandler,
                        StylusOptimizer

  serve:->
    root = @config.server.root
    port = @config.server.port

    # simple static server with 'connect'
    @conn = (conn().use conn.static root ).listen port
    address = 'http://localhost:' + port
    log 'Server running at ' + address.green
  
  compile:->
    for type_str, type of @filetype
      do type.compile_files_to_disk

  watch:->
    for type_str, type of @filetype
      do type.watch

  optimize:->
    for type_str, type of @filetype
      do type.optimize

  reset:()->
    # close all builder's watchers
    @conn.close() if @conn?
    for type_str, type of @filetype
      do type.close_watchers