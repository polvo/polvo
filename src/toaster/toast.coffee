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


module.exports = class Toast

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

  constructor:(@toaster, @cli, @config)->
    # initialize
    @init() if @cli.argv.c or @cli.argv.w or @cli.argv.r

    # starts watching if -w is given
    @watch() if @cli.argv.w

    # starts serving static files
    setTimeout (=> @serve()), 1 if @cli.argv.s

  init:()->
    @filetype = 
      coffee: new Tree @toaster, @cli, @config, @, CoffeeHandler, CoffeeOptimizer

  serve:->
    return if @config.browser is null

    root = @config.browser.server.root
    port = @config.browser.server.port

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