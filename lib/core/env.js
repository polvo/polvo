/**
 * Core modules
 */

var 
  fs = require('fs'),
  path = require('path');

/**
 * NPM modules
 */
var
  _ = require('lodash'),
  debug = require('debug')('polvo:core:env');


/**
 * Constructs a new Env
 * @param  {String} name Env name
 * @return {Env} New env instance
 */
module.exports = function(name) {
  return new Env(name);
};



/**
 * Env class holds all the environments properties
 * @param {String} name   Env name
 */
function Env(name) {

  /**
   * Env name/id
   * @type {String}
   */
  this.name = name;

  /**
   * Env settings
   * @type {Object}
   */
  this.settings = {

    /**
     * Input paths
     * @type {Array}
     */
    input: [],

    /**
     * Output paths
     * @type {Object}
     */
    output: {},

    /**
     * Minify options
     * @type {Object}
     */
    minify: {},

    /**
     * Server configs
     * @type {Object}
     */
    server: {

      /**
       * Server port
       * @type {Number}
       */
      port: 3000
    },

    /**
     * General options
     * @type {Object}
     */
    options: {
      /**
       * Enables/disables watch mode
       * @type {Boolean}
       */
      watch: false,

      /**
       * Enables/disables concatenation for single file output
       * @type {Boolean}
       */
      concat: true,

      /**
       * Enables/disables webserver
       * @type {Boolean}
       */
      server: false,

      /**
       * Enables / disables REPL server
       * @type {Boolean}
       */
      repl: true
    }
  };
}

/**
 * Sets input paths
 * @param  {Object} paths One {string} or an {array} of {string}
 * @return {Env}  Self reference for chaining
 */
Env.prototype.input = function(paths) {
  var inputs = this.settings.input;

  paths = [].concat(paths);
  if(!paths.length)
    return debug('No input set');

  paths.forEach(function(val) {
    val = path.resolve(val);
    if(!fs.existsSync(val))
      return debug('Input path not found: %s', val);
    inputs.push(val);
  });

  return this;
};

/**
 * Set output paths
 * @param  {Object} paths Key/value pairs where key=filetype, value=filepath
 * @return {Env}  Self reference for chaining
 */
Env.prototype.output = function(paths) {
  var self = this;

  if(!paths.js && !paths.css)
    throw new Error('No output informed');

  ['js', 'css'].forEach(function(prop) {
    var folderpath, filepath = paths[prop];
    if(filepath && !fs.existsSync(path.dirname(filepath))) {
      folderpath = path.dirname(filepath);
      return debug('Output folder for `%s` not found: %s', prop, folderpath);
    }
    self.settings.output[prop] = filepath;
  });

  return this;
};

/**
 * Set server options
 * @param  {Object} Key options are 'port' and 'root'
 * @return {Env}  Self reference for chaining
 */
Env.prototype.server = function(options) {
  if(options.root) {
    options.root = path.resolve(options.root);
    if(!fs.existsSync(options.root))
      return debug('Server root folder not found: %s', options.root);
  }
  _.merge(this.settings.server, options);
  return this;
};

/**
 * Set minify options per output format
 * @param  {Object} Key options are 'js' and 'css'
 * @return {Env}  Self reference for chaining
 */
Env.prototype.minify = function(options) {
  _.merge(this.settings.minify, options);
  return this;
};

/**
 * Set general options
 * @param  {options} General options (all {Boolean}): watch, split, server,
 * port, repl
 * @return {Env}  Self reference for chaining
 */
Env.prototype.options = function(options) {
  _.merge(this.settings.options, options);
  return this;
};