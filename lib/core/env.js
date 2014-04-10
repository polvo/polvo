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
module.exports = function(app, name) {
  return new Env(app, name);
};



/**
 * Env class holds all the environments properties
 * @param {String} name   Env name
 */
function Env(app, name) {

  /**
   * App reference
   * @type {Application}
   */
  this.app = app;

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
    minify: {
      js: false,
      css: false
    },

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
  var base = this.app.base_dir;

  if(!paths)
    throw new Error('Input can\'t be blank');

  paths = [].concat(paths);
  paths.forEach(function(val) {
    val = resolve(base, val);
    if(!fs.existsSync(val))
      throw new Error('Input path not found: ' + val);
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
  var filepath, folderpath, self = this, base = this.app.base_dir;

  if(!paths || (!paths.js && !paths.css))
    throw new Error('Output not set');

  ['js', 'css'].forEach(function(prop) {
    if(!paths[prop]) return;

    filepath = resolve(base, paths[prop]);
    folderpath = path.dirname(filepath);
    
    if(!fs.existsSync(folderpath))
      throw new Error('Output folder for '+ prop +' not found: ' + folderpath);

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
  var base = this.app.base_dir;
  if(options.root) {
    options.root = resolve(base, options.root);
    if(!fs.existsSync(options.root))
      throw new Error('Server root folder not found: '+ options.root);
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


function resolve(base, filepath) {
  if(path.resolve(filepath) == filepath)
    return filepath;
  return path.join(base, filepath);
}