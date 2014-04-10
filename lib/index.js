/**
 * Core modules
 */
var fs = require('fs');
var path = require('path');
var _ = require('lodash');

/**
 * NPM modules
 */
var debug = require('debug')('polvo');
var happens = require('happens');

/**
 * Lib modules
 */
var env = require('./core/env');
// var assembler = require('./core/assembler');
// var server = require('./core/server');


/**
 * Module constructor
 * @return {Application} New application instance
 */
module.exports = function() {
  return new Application(null);
};



/**
 * Crates a new polvo application
 * @param {options} Cli options parser instance
 */
function Application() {

  /**
   * Holds all envs configs
   * @type {Object}
   */
  this.envs = {};

  /**
   * Middlewares array
   * @type {Array}
   */
  this.middlewares = [];
}

/**
 * Set middlewares
 * @param  {Function} middleware  Middleware reference
 */
Application.prototype.use = function(middleware) {
  debug('use ', middleware);
  this.middlewares.push(middleware);
};

/**
 * Configures a new environment
 * @param  {String} env_names One or more env name, space separated
 */
Application.prototype.env = function(env_names) {
  return config_chain(this, [].concat(env_names.split(' ')));
};

/**
 * Starts polvo application for the given env
 * @param  {String} env_name Env to start application upon
 */
Application.prototype.run = function(env_name) {
  debug('run', event_name);

  // var env = this.envs[env_name];

  // assembler.build(env);

  // if(env.server)
  //   server.start(env);

  this.emit('run');
};

/**
 * Close all open connections and file descriptions for a graceful exit
 */
Application.prototype.end = function(){
  this.emit('end');
  server.close();
};



/**
 * Constructs a function that widely-applies values for all envs in parallel
 * @param  {Application} app App reference
 * @param  {Array} envs Envs array
 * @param  {String} method Method name
 * @param  {Object} methods Chained methods' stack
 * @return {Function} Dynamically created bulk-apply method
 */
function bulk_apply(app, envs, method, methods) {
  return function(val) {
    envs.forEach(function(e){
      (app.envs[e] = app.envs[e] || env(e))[method](val);
    });
    return methods;
  };
}

/**
 * Construct a set of methods that can be chained for configuring envs
 * @param  {Application} app App reference
 * @param  {Array} envs Envs array
 * @return {Object} Methods chain, ready for use
 */
function config_chain(app, envs) {
  var methods = {};

  methods.input = bulk_apply(app, envs, 'input', methods);
  methods.output = bulk_apply(app, envs, 'output', methods);
  methods.minify = bulk_apply(app, envs, 'minify', methods);
  methods.server = bulk_apply(app, envs, 'server', methods);
  methods.options = bulk_apply(app, envs, 'options', methods);
  methods.inherit = function(from) {
    var source;
    if(!(source = app.envs[from]))
      return debug('Cannot inherit from %s, env not found.', from);

    envs.forEach(function(e){
      var into = app.envs[e] || (app.envs[e] = env(e));
      _.merge(into.settings, source.settings);
    });

    return methods;
  };

  return methods;
}