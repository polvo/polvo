// Generated by CoffeeScript 1.6.3
(function() {
  var Cli, File, Files, compiler, config, fsu, path, plugins, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  path = require('path');

  fsu = require('fs-util');

  _ = require('lodash');

  config = require('../utils/config');

  compiler = require('./compiler');

  plugins = require('../utils/plugins');

  File = require('./file');

  Cli = require('../cli');

  module.exports = new (Files = (function() {
    var argv, cli, exts, plugin;

    argv = (cli = new Cli).argv;

    exts = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = plugins.length; _i < _len; _i++) {
        plugin = plugins[_i];
        _results.push(plugin.ext);
      }
      return _results;
    })();

    Files.prototype.files = null;

    Files.prototype.watchers = null;

    function Files() {
      this.onfschange = __bind(this.onfschange, this);
      this.new_deps = __bind(this.new_deps, this);
      var dirpath, filepath, _i, _j, _len, _len1, _ref, _ref1;
      this.files = [];
      _ref = config.input;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dirpath = _ref[_i];
        _ref1 = fsu.find(dirpath, exts);
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          filepath = _ref1[_j];
          this.new_file(filepath);
        }
      }
      if (argv.watch) {
        this.watch();
      }
    }

    Files.prototype.has_compiler = function(filepath) {
      var ext, _i, _len;
      for (_i = 0, _len = exts.length; _i < _len; _i++) {
        ext = exts[_i];
        if (ext.test(filepath)) {
          return true;
        }
      }
      return false;
    };

    Files.prototype.new_file = function(filepath) {
      var file;
      if (!this.has_compiler(filepath)) {
        return;
      }
      if (_.find(this.files, {
        filepath: filepath
      })) {
        return;
      }
      file = new File(filepath);
      file.on('deps', this.new_deps);
      file.init();
      return this.files.push(file);
    };

    Files.prototype.new_deps = function(deps) {
      var dep, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = deps.length; _i < _len; _i++) {
        dep = deps[_i];
        _results.push(this.new_file(dep));
      }
      return _results;
    };

    Files.prototype.watch = function() {
      var dirpath, location, name, watcher, watchers, _i, _len, _ref, _ref1, _results,
        _this = this;
      watchers = [];
      _ref = config.input;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dirpath = _ref[_i];
        watchers.push((watcher = fsu.watch(dirpath, exts)));
        watcher.on('create', function(file) {
          return _this.onfschange(false, dirpath, 'create', file);
        });
        watcher.on('change', function(file) {
          return _this.onfschange(false, dirpath, 'change', file);
        });
        watcher.on('delete', function(file) {
          return _this.onfschange(false, dirpath, 'delete', file);
        });
      }
      _ref1 = config.vendors.js;
      _results = [];
      for (name in _ref1) {
        location = _ref1[name];
        watchers.push((watcher = fsu.watch(location)));
        watcher.on('create', function(file) {
          return _this.onfschange(true, dirpath, 'create', file);
        });
        watcher.on('change', function(file) {
          return _this.onfschange(true, dirpath, 'change', file);
        });
        _results.push(watcher.on('delete', function(file) {
          return _this.onfschange(true, dirpath, 'delete', file);
        }));
      }
      return _results;
    };

    Files.prototype.close_watchers = function() {
      var watcher, _i, _len, _ref, _results;
      _ref = this.watchers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        watcher = _ref[_i];
        _results.push(watcher.close());
      }
      return _results;
    };

    Files.prototype.onfschange = function(vendor, dirpath, action, file) {
      var index, location, msg, type;
      location = file.location, type = file.type;
      if (type === "dir" && action === "create") {
        return;
      }
      switch (action) {
        case "create":
          this.new_file(filepath);
          msg = ("+ " + type + " created").bold;
          console.log(("" + msg + " " + location).cyan);
          return compiler.build();
        case "delete":
          file = _.find(this.files, {
            filepath: location
          });
          index = _.indexOf(this.files, {
            filepath: location
          });
          if (file != null) {
            this.files.splice(index, 1);
            msg = ("- " + type + " deleted").bold;
            compiler.build();
            return console.log(("" + msg + " " + location).red);
          }
          break;
        case "change":
          file = _.find(this.files, {
            filepath: location
          });
          if (file === null && vendor === false) {
            msg = "Change file is apparently null, it shouldn't happened.\n";
            msg += "Please report this at the repo issues section.";
            console.warn(msg);
          } else {
            msg = ("• " + type + " changed").bold;
            console.log(("" + msg + " " + location).cyan);
          }
          if (!vendor) {
            file.refresh();
          }
          return compiler.build();
      }
    };

    return Files;

  })());

}).call(this);

/*
//@ sourceMappingURL=files.map
*/