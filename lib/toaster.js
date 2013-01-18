var __t;

__t = function(ns) {
  var curr, index, part, parts, _i, _len;
  curr = null;
  parts = [].concat = ns.split(".");
  for (index = _i = 0, _len = parts.length; _i < _len; index = ++_i) {
    part = parts[index];
    if (curr === null) {
      curr = eval(part);
      continue;
    } else {
      if (curr[part] == null) {
        curr = curr[part] = {};
      } else {
        curr = curr[part];
      }
    }
  }
  return curr;
};

var toaster = exports.toaster = {};

(function() {
  var ObjectUtil, Toaster, debug, error, exec, fs, growl, icon_error, icon_warn, interval, log, msgs, os, path, process_msgs, queue_msg, start_worker, stop_worker, warn,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  __t('toaster').Toast = (function() {
    var colors, cs, exec, fs, fsu, path;

    fs = require("fs");

    fsu = require("fs-util");

    path = require("path");

    exec = (require("child_process")).exec;

    colors = require('colors');

    cs = require("coffee-script");

    Toast.prototype.builders = null;

    function Toast(toaster) {
      var code, config, config_file, contents, filepath, fix_scope, item, watcher, _i, _len, _ref,
        _this = this;
      this.toaster = toaster;
      this.toast = __bind(this.toast, this);

      this.basepath = this.toaster.basepath;
      this.builders = [];
      if ((config = this.toaster.cli.argv["config"]) != null) {
        if (!(config instanceof Object)) {
          config = JSON.parse(config);
        }
        _ref = [].concat(config);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          this.toast(item);
        }
      } else {
        config_file = this.toaster.cli.argv["config-file"];
        filepath = config_file || path.join(this.basepath, "toaster.coffee");
        if (this.toaster.cli.argv.w) {
          watcher = fsu.watch(filepath);
          watcher.on('change', function(f) {
            var now;
            now = (("" + (new Date)).match(/[0-9]{2}\:[0-9]{2}\:[0-9]{2}/))[0];
            log(("[" + now + "] " + 'Changed'.bold + " " + filepath).cyan);
            watcher.close();
            return _this.toaster.reset();
          });
        }
        if (fs.existsSync(filepath)) {
          contents = fs.readFileSync(filepath, "utf-8");
          try {
            code = cs.compile(contents, {
              bare: 1
            });
          } catch (err) {
            error(err.message + " at 'toaster.coffee' config file.");
          }
          fix_scope = /(^[\s\t]?)(toast)+(\()/mg;
          code = code.replace(fix_scope, "$1this.$2$3");
          eval(code);
        } else {
          error("File not found: ".yellow + (" " + filepath.red + "\n") + "Try running:".yellow + " toaster -i".green + " or type".yellow + (" " + 'toaster -h'.green + " ") + "for more info".yellow);
        }
      }
    }

    Toast.prototype.toast = function(srcpath, params) {
      var alias, builder, config, debug, dir, folder, item, _base, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4;
      if (params == null) {
        params = {};
      }
      if (srcpath instanceof Object) {
        params = srcpath;
      } else if (path.resolve(srcpath !== srcpath)) {
        folder = path.join(this.basepath, srcpath);
      }
      if (params.release === null) {
        error('Release path not informed in config.');
        return process.exit();
      } else {
        dir = path.dirname(params.release);
        if (!fs.existsSync(path.join(this.basepath, dir))) {
          error("Release folder does not exist:\n\t" + dir.yellow);
          return process.exit();
        }
      }
      if (params.nature.browser != null) {
        if ((_ref = (_base = params.nature.browser).minify) == null) {
          _base.minify = true;
        }
      }
      if (params.debug) {
        debug = path.join(this.basepath, params.debug);
      } else {
        debug = null;
      }
      config = {
        src_folders: [],
        nature: params.nature,
        exclude: (_ref1 = params.exclude) != null ? _ref1 : [],
        bare: (_ref2 = params.bare) != null ? _ref2 : true,
        release: path.join(this.basepath, params.release)
      };
      if (!(srcpath instanceof Object)) {
        srcpath = path.resolve(path.join(this.basepath, srcpath));
        config.src_folders.push({
          path: srcpath,
          alias: params.alias || null
        });
      }
      if (params.folders != null) {
        _ref3 = params.folders;
        for (folder in _ref3) {
          alias = _ref3[folder];
          if ((path.resolve(folder)) !== folder) {
            folder = path.join(this.basepath, folder);
          }
          config.src_folders.push({
            path: folder,
            alias: alias
          });
        }
      }
      _ref4 = config.src_folders;
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        item = _ref4[_i];
        if (!fs.existsSync(item.path)) {
          error(("Source folder doens't exist:\n\t" + item.path.red + "\n") + ("Check your " + 'toaster.coffee'.yellow + " and try again.") + "\n\t" + (path.join(this.basepath, "toaster.coffee")).yellow);
          return process.exit();
        }
      }
      builder = new toaster.core.Builder(this.toaster, this.toaster.cli, config);
      return this.builders.push(builder);
    };

    return Toast;

  })();

  __t('toaster.generators').Question = (function() {

    function Question() {}

    Question.prototype.ask = function(question, format, fn) {
      var stdin, stdout,
        _this = this;
      stdin = process.stdin;
      stdout = process.stdout;
      stdout.write("" + question + " ");
      return stdin.once('data', function(data) {
        var msg, rule;
        data = data.toString().trim();
        if (format.test(data)) {
          return fn(data.trim());
        } else {
          msg = "" + 'Invalid entry, it should match:'.red;
          rule = "" + (format.toString().cyan);
          stdout.write("\t" + msg + " " + rule + "\n");
          return _this.ask(question, format, fn);
        }
      }).resume();
    };

    return Question;

  })();

  __t('toaster.utils').ObjectUtil = (function() {

    function ObjectUtil() {}

    /*
      @param [] str
      @param [] search
      @param [Boolean] strong_typing
    */


    ObjectUtil.find = function(src, search, strong_typing) {
      var k, v;
      if (strong_typing == null) {
        strong_typing = false;
      }
      for (k in search) {
        v = search[k];
        if (v instanceof Object) {
          return ObjectUtil.find(src[k], v);
        } else if (strong_typing) {
          if (src[k] === v) {
            return src;
          }
        } else {
          if (("" + src[k]) === ("" + v)) {
            return src;
          }
        }
      }
      return null;
    };

    return ObjectUtil;

  })();

  __t('toaster.utils').FnUtil = (function() {

    function FnUtil() {}

    FnUtil.proxy = function() {
      var fn, params;
      fn = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return function() {
        var inner_params;
        inner_params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return fn.apply(null, params.concat(inner_params));
      };
    };

    return FnUtil;

  })();

  os = require('os');

  growl = os.platform() === 'win32' ? null : require('growl');

  icon_warn = __dirname + '/../images/warning.png';

  icon_error = __dirname + '/../images/error.png';

  log = function(msg, send_to_growl) {
    if (send_to_growl == null) {
      send_to_growl = false;
    }
    console.log(msg);
    return msg;
  };

  debug = function(msg, send_to_growl) {
    if (send_to_growl == null) {
      send_to_growl = false;
    }
    msg = log("" + msg.magenta);
    return msg;
  };

  error = function(msg, send_to_growl, file) {
    if (send_to_growl == null) {
      send_to_growl = true;
    }
    if (file == null) {
      file = null;
    }
    msg = log("ERROR ".bold.red + msg);
    if (send_to_growl && (growl != null)) {
      msg = msg.replace(/\[\d{2}m/g, "");
      msg = msg.replace(/(\[\dm)([^\s]+)/ig, "<$2>$3");
      queue_msg({
        msg: msg,
        opts: {
          title: 'Coffee Toaster',
          image: icon_error
        }
      });
    }
    return msg;
  };

  warn = function(msg, send_to_growl) {
    if (send_to_growl == null) {
      send_to_growl = true;
    }
    msg = log("WARNING ".bold.yellow + msg);
    if (send_to_growl && (growl != null)) {
      msg = msg.replace(/\[\d{2}m/g, "");
      msg = msg.replace(/(\[\dm)([^\s]+)/ig, "<$2>$3");
      queue_msg({
        msg: msg,
        opts: {
          title: 'Coffee Toaster',
          image: icon_warn
        }
      });
    }
    return msg;
  };

  msgs = [];

  interval = null;

  start_worker = function() {
    if (interval == null) {
      interval = setInterval(process_msgs, 150);
      return process_msgs();
    }
  };

  stop_worker = function() {
    if (interval != null) {
      clearInterval(interval);
      return interval = null;
    }
  };

  queue_msg = function(msg) {
    msgs.push(msg);
    return start_worker();
  };

  process_msgs = function() {
    var msg;
    if (msgs.length) {
      msg = msgs.shift();
      return growl.notify(msg.msg, msg.opts);
    } else {
      return stop_worker();
    }
  };

  ObjectUtil = toaster.utils.ObjectUtil;

  __t('toaster.utils').ArrayUtil = (function() {

    function ArrayUtil() {}

    ArrayUtil.find = function(src, search) {
      var i, v, _i, _len;
      for (i = _i = 0, _len = src.length; _i < _len; i = ++_i) {
        v = src[i];
        if (!(search instanceof Object)) {
          if (v === search) {
            return {
              item: v,
              index: i
            };
          }
        } else {
          if (ObjectUtil.find(v, search) != null) {
            return {
              item: v,
              index: i
            };
          }
        }
      }
      return null;
    };

    ArrayUtil["delete"] = function(src, search) {
      var item;
      item = ArrayUtil.find(src, search);
      if (item != null) {
        return src.splice(item.index, 1);
      }
    };

    ArrayUtil.has = function(source, search) {
      return (ArrayUtil.find(source, search)) != null;
    };

    ArrayUtil.replace_into = function(src, index, items) {
      items = [].concat(items);
      src.splice(index, 1);
      while (items.length) {
        src.splice(index++, 0, items.shift());
      }
      return src;
    };

    return ArrayUtil;

  })();

  __t('toaster.utils').StringUtil = (function() {

    function StringUtil() {}

    StringUtil.titleize = function(str) {
      var index, word, words, _i, _len;
      words = str.match(/[a-z]+/gi);
      for (index = _i = 0, _len = words.length; _i < _len; index = ++_i) {
        word = words[index];
        words[index] = StringUtil.ucasef(word);
      }
      return words.join(" ");
    };

    StringUtil.ucasef = function(str) {
      var output;
      output = str.substr(0, 1).toUpperCase();
      return output += str.substr(1).toLowerCase();
    };

    return StringUtil;

  })();

  __t('toaster.core').Script = (function() {
    var ArrayUtil, cs, fs, path, uglify, uglify_parser;

    fs = require("fs");

    path = require('path');

    cs = require("coffee-script");

    uglify = require("uglify-js").uglify;

    uglify_parser = require("uglify-js").parser;

    ArrayUtil = toaster.utils.ArrayUtil;

    function Script(builder, folderpath, realpath, alias, opts) {
      this.builder = builder;
      this.folderpath = folderpath;
      this.realpath = realpath;
      this.alias = alias;
      this.opts = opts;
      this.getinfo();
    }

    Script.prototype.getinfo = function(declare_ns) {
      var absolute_path, baseclass, dep, deps, folder_path, klass, match, release_path, require_reg_all, require_reg_one, rgx, rgx_ext, search, _i, _j, _len, _len1, _ref, _ref1;
      if (declare_ns == null) {
        declare_ns = true;
      }
      this.raw = fs.readFileSync(this.realpath, "utf-8");
      this.dependencies = [];
      this.baseclasses = [];
      this.filepath = this.realpath.replace(this.folderpath, '');
      search = "" + this.builder.toaster.basepath + path.sep;
      this.relative_path = this.filepath.replace(search, '');
      this.relative_path = this.relative_path.replace('.coffee', '.js');
      release_path = path.dirname(this.builder.release);
      absolute_path = path.resolve(path.join(release_path, this.relative_path));
      folder_path = path.dirname(absolute_path);
      this.release = {
        folder: folder_path,
        file: absolute_path
      };
      if ((this.filepath.substr(0, 1)) === path.sep) {
        this.filepath = this.filepath.substr(1);
      }
      this.filename = path.basename(this.filepath);
      this.filefolder = path.dirname(this.filepath);
      this.namespace = "";
      if (this.filepath.indexOf(path.sep) === -1) {
        this.filefolder = "";
      }
      this.namespace = this.filefolder.replace(new RegExp("\\" + path.sep, "g"), ".");
      this.namespace = this.namespace.replace(/^\.?(.*)\.?$/g, "$1");
      rgx = /^(class)+\s+([^\s]+)+(\s(extends)\s+([\w.]+))?/mg;
      rgx_ext = /(^|=\s*)(class)\s(\w+)\s(extends)\s(\\w+)\s*$/gm;
      if (this.raw.match(rgx) != null) {
        this.classname = (this.raw.match(/class\s([^\s]+)/))[1];
        this.classpath = "" + this.namespace + "." + this.classname;
        _ref1 = (_ref = this.raw.match(rgx_ext)) != null ? _ref : [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          klass = _ref1[_i];
          baseclass = klass.match(rgx_ext)[5];
          this.baseclasses.push(baseclass);
        }
      }
      require_reg_all = /^([^\s]+)\s*=\s*require\s(?:'|")(.*)(?:'|")/mg;
      require_reg_one = /^([^\s]+)\s*=\s*require\s(?:'|")(.*)(?:'|")/m;
      if (require_reg_all.test(this.raw)) {
        deps = this.raw.match(require_reg_all);
        for (_j = 0, _len1 = deps.length; _j < _len1; _j++) {
          dep = deps[_j];
          this.raw = this.raw.replace(dep, "# " + dep);
          match = dep.match(require_reg_one);
          dep = {
            name: match[1],
            path: match[2] + '.coffee'
          };
          this.dependencies.push(dep);
        }
      }
      this.backup = this.raw;
      return this.inject_definitions();
    };

    Script.prototype.inject_definitions = function() {
      var def, dep, deps_args, deps_path, identation, idented, match_identation, _i, _len, _ref;
      if (this.builder.nature.browser == null) {
        return;
      }
      deps_path = '';
      deps_args = '';
      _ref = this.dependencies;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dep = _ref[_i];
        deps_path += "'" + (dep.path.replace('.coffee', '')) + "',\n";
        deps_args += "" + dep.name + ",";
      }
      deps_path = deps_path.slice(0, -1);
      deps_args = deps_args.slice(0, -1);
      match_identation = /^([\s]+).*$/mg;
      while (identation !== '\s' && identation !== '\t') {
        identation = (match_identation.exec(this.raw))[1];
      }
      idented = this.backup.replace(/^/mg, "" + identation);
      this.raw = "define [" + deps_path + "], ( " + deps_args + " )-> \n" + idented;
      def = this.filepath.replace('.coffee', '');
      return this.defined_raw = "define '" + def + "', [" + deps_path + "], ( " + deps_args + " )-> \n" + idented;
    };

    Script.prototype.delete_compiled_from_disk = function() {
      if (fs.existsSync(this.release.folder)) {
        return fs.unlinkFileSync(this.release.file);
      }
    };

    Script.prototype.compile_to_disk = function() {
      var compiled, now;
      now = (("" + (new Date)).match(/[0-9]{2}\:[0-9]{2}\:[0-9]{2}/))[0];
      compiled = this.compile_to_str();
      if (!fs.existsSync(this.release.folder)) {
        fsu.mkdir_p(this.release.folder);
      }
      fs.writeFileSync(this.release.file, compiled);
      return log(("[" + now + "] " + 'Compiled'.bold + " " + this.relative_path).green);
    };

    Script.prototype.compile_to_str = function() {
      var ast, compiled;
      compiled = cs.compile(this.raw, {
        bare: this.builder.bare
      });
      if ((this.builder.nature.browser != null) && this.builder.cli.argv.r && this.builder.minify) {
        ast = uglify_parser.parse(compiled);
        ast = uglify.ast_mangle(ast);
        ast = uglify.ast_squeeze(ast);
        compiled = uglify.gen_code(ast);
      }
      return compiled;
    };

    return Script;

  })();

  __t('toaster').Cli = (function() {
    var optimist;

    optimist = require('optimist');

    function Cli() {
      var usage;
      usage = "" + 'CoffeeToaster'.bold + "\n";
      usage += "  Minimalist build system for CoffeeScript\n\n".grey;
      usage += "" + 'Usage:' + "\n";
      usage += "  toaster [" + 'options'.green + "] [" + 'path'.green + "]\n\n";
      usage += "" + 'Examples:' + "\n";
      usage += "  toaster -n myawsomeapp   (" + 'required'.red + ")\n";
      usage += "  toaster -i [myawsomeapp] (" + 'optional'.green + ")\n";
      usage += "  toaster -c [myawsomeapp] (" + 'optional'.green + ")\n";
      usage += "  toaster -w [myawsomeapp] (" + 'optional'.green + ")\n";
      usage += "  toaster -wa [myawsomeapp] (" + 'optional'.green + ")\n";
      this.argv = (this.opts = optimist.usage(usage).alias('n', 'new').describe('n', "Scaffold a very basic new App.").alias('i', 'init').describe('i', "Create a config (toaster.coffee) file for existing projects.").alias('w', 'watch').describe('w', "Start watching/compiling in dev mode.").alias('c', 'compile').describe('c', "Compile project in dev mode.").alias('r', 'release').describe('r', "Compile project in release mode.").alias('a', 'autorun').describe('a', 'Execute the script in node.js after compilation.').alias('j', 'config').string('j').describe('j', "Config file formatted as a json-string.").alias('f', 'config-file').string('f').describe('f', "Path to a different config file.").alias('v', 'version').describe('v', '').alias('h', 'help').describe('h', '')).argv;
    }

    return Cli;

  })();

  __t('toaster.core').Builder = (function() {
    var ArrayUtil, FnUtil, Script, StringUtil, cp, cs, fs, fsu, missing, path, _ref;

    fs = require('fs');

    fsu = require('fs-util');

    path = require('path');

    cs = require("coffee-script");

    cp = require("child_process");

    Script = toaster.core.Script;

    _ref = toaster.utils, FnUtil = _ref.FnUtil, ArrayUtil = _ref.ArrayUtil, StringUtil = _ref.StringUtil;

    Builder.prototype.watchers = null;

    function Builder(toaster, cli, config) {
      this.toaster = toaster;
      this.cli = cli;
      this.config = config;
      this.on_fs_change = __bind(this.on_fs_change, this);

      this.build = __bind(this.build, this);

      this.bare = this.config.bare;
      this.exclude = [].concat(this.config.exclude);
      this.release = this.config.release;
      this.nature = this.config.nature;
      if (this.config.nature.browser) {
        this.base_url = this.nature.browser.base_url;
        this.minify = this.nature.browser.minify;
      } else {
        this.minify = false;
      }
      this.init();
      if (this.cli.argv.w) {
        this.watch();
      }
    }

    Builder.prototype.init = function() {
      var falias, file, folder, fpath, include, item, result, _i, _len, _ref1, _results;
      this.files = [];
      _ref1 = this.config.src_folders;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        folder = _ref1[_i];
        result = fsu.find(folder.path, /.coffee$/m);
        fpath = folder.path;
        falias = folder.alias;
        _results.push((function() {
          var _j, _k, _len1, _len2, _ref2, _results1;
          _results1 = [];
          for (_j = 0, _len1 = result.length; _j < _len1; _j++) {
            file = result[_j];
            include = true;
            _ref2 = this.exclude;
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              item = _ref2[_k];
              include &= !(new RegExp(item).test(file));
            }
            if (include) {
              _results1.push(this.files.push(new Script(this, fpath, file, falias, this.cli)));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Builder.prototype.reset = function() {
      var watcher, _i, _len, _ref1, _results;
      _ref1 = this.watchers;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        watcher = _ref1[_i];
        _results.push(watcher.close());
      }
      return _results;
    };

    Builder.prototype.build = function() {
      var args, i, _i, _ref1;
      this.compile();
      if (this.cli.argv.a) {
        args = [];
        if (process.argv.length > 3) {
          for (i = _i = 3, _ref1 = process.argv.length; _i < _ref1; i = _i += 1) {
            args.push(process.argv[i]);
          }
        }
        if (this.child != null) {
          log("Application restarted:".blue);
          this.child.kill('SIGHUP');
        } else {
          log("Application started:".blue);
        }
        if (this.cli.argv.d) {
          return this.child = cp.fork(this.release, args, {
            execArgv: ['--debug-brk']
          });
        } else {
          return this.child = cp.fork(this.release, args);
        }
      }
    };

    Builder.prototype.watch = function() {
      var src, watcher, _i, _len, _ref1, _results;
      this.watchers = [];
      _ref1 = this.config.src_folders;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        src = _ref1[_i];
        this.watchers.push((watcher = fsu.watch(src.path, /.coffee$/m)));
        watcher.on('create', FnUtil.proxy(this.on_fs_change, src, 'create'));
        watcher.on('change', FnUtil.proxy(this.on_fs_change, src, 'change'));
        _results.push(watcher.on('delete', FnUtil.proxy(this.on_fs_change, src, 'delete')));
      }
      return _results;
    };

    Builder.prototype.on_fs_change = function(src, ev, f) {
      var falias, file, fpath, include, item, msg, now, relative_path, script, spath, type, _i, _len, _ref1;
      if (f.type === "dir" && ev === "create") {
        return;
      }
      fpath = f.location;
      spath = src.path;
      if (src.alias !== '') {
        falias = path.sep + src.alias;
      } else {
        falias = '';
      }
      include = true;
      _ref1 = this.exclude;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        item = _ref1[_i];
        include &= !(new RegExp(item).test(fpath));
      }
      if (!include) {
        return;
      }
      type = StringUtil.titleize(f.type);
      relative_path = fpath.replace(spath, falias);
      if (relative_path[0] === path.sep) {
        relative_path = relative_path.substr(1);
      }
      now = (("" + (new Date)).match(/[0-9]{2}\:[0-9]{2}\:[0-9]{2}/))[0];
      switch (ev) {
        case "create":
          msg = "" + ('New ' + f.type + ' created').bold;
          log(("[" + now + "] " + msg + " " + f.location).cyan);
          this.files.push(script = new Script(this, spath, fpath, falias, this.cli));
          return script.compile_to_disk();
        case "delete":
          file = ArrayUtil.find(this.files, {
            'filepath': relative_path
          });
          if (file === null) {
            return;
          }
          file.item.delete_compiled();
          this.files.splice(file.index, 1);
          msg = "" + (type + ' deleted, stop watching').bold;
          return log(("[" + now + "] " + msg + " " + f.location).red);
        case "change":
          file = ArrayUtil.find(this.files, {
            'filepath': relative_path
          });
          if (file === null) {
            return warn("CHANGED FILE IS APPARENTLY NULL...");
          } else {
            msg = "" + (type + ' changed').bold;
            log(("[" + now + "] " + msg + " " + relative_path).cyan);
            file.item.getinfo();
            return file.item.compile_to_disk();
          }
      }
    };

    Builder.prototype.compile = function() {
      var file, index, _i, _len, _ref1, _results;
      _ref1 = this.files;
      _results = [];
      for (index = _i = 0, _len = _ref1.length; _i < _len; index = ++_i) {
        file = _ref1[index];
        _results.push(file.compile_to_disk());
      }
      return _results;
    };

    missing = {};

    Builder.prototype.reorder = function(cycling) {
      var bc, dep, dependency, dependency_index, file, file_index, filepath, found, i, index, not_found, _i, _j, _len, _len1, _ref1, _ref2, _results;
      if (cycling == null) {
        cycling = false;
      }
      if (cycling === false) {
        this.missing = {};
      }
      _ref1 = this.files;
      _results = [];
      for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
        file = _ref1[i];
        if (!file.dependencies.length && !file.baseclasses.length) {
          continue;
        }
        _ref2 = file.dependencies;
        for (index = _j = 0, _len1 = _ref2.length; _j < _len1; index = ++_j) {
          dep = _ref2[index];
          filepath = dep.path;
          dependency = ArrayUtil.find(this.files, {
            'filepath': filepath
          });
          if (dependency != null) {
            dependency_index = dependency.index;
          }
          if (dependency_index < i && (dependency != null)) {
            continue;
          }
          if (dependency != null) {
            if (ArrayUtil.has(dependency.item.dependencies, {
              'filepath': file.filepath
            })) {
              file.dependencies.splice(index, 1);
              warn("Circular dependency found between ".yellow + filepath.grey.bold + " and ".yellow + file.filepath.grey.bold);
              continue;
            } else {
              this.files.splice(index, 0, dependency.item);
              this.files.splice(dependency.index + 1, 1);
              this.reorder(true);
              break;
            }
          } else if (this.missing[filepath] !== true) {
            this.missing[filepath] = true;
            file.dependencies.push(filepath);
            file.dependencies.splice(index, 1);
            warn(("" + 'Dependency'.yellow + " " + filepath.bold.grey + " ") + ("" + 'not found for file'.yellow + " ") + file.filepath.grey.bold);
          }
        }
        file_index = ArrayUtil.find(this.files, {
          'filepath': file.filepath
        });
        file_index = file_index.index;
        _results.push((function() {
          var _k, _len2, _ref3, _results1;
          _ref3 = file.baseclasses;
          _results1 = [];
          for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
            bc = _ref3[_k];
            found = ArrayUtil.find(this.files, bc, "classname");
            not_found = (found === null) || (found.index > file_index);
            if (not_found && !this.missing[bc]) {
              this.missing[bc] = true;
              _results1.push(warn("Base class ".yellow + ("" + bc + " ").bold.grey + "not found for class ".yellow + ("" + file.classname + " ").bold.grey + "in file ".yellow + file.filepath.bold.grey));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return Builder;

  })();

  __t('toaster.generators').Config = (function(_super) {
    var fs, path;

    __extends(Config, _super);

    path = require("path");

    fs = require("fs");

    Config.prototype.tpl = "# => SRC FOLDER\ntoast '%src%'\n\n  # EXCLUDED FOLDERS (optional)\n  # exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]\n\n  # => VENDORS (optional)\n  # vendors: ['vendors/x.js', 'vendors/y.js', ... ]\n\n  # => OPTIONS (optional, default values listed)\n  # bare: false\n  # packaging: true\n  # expose: ''\n  # minify: true\n\n  # => HTTPFOLDER (optional), RELEASE / DEBUG (required)\n  httpfolder: '%httpfolder%'\n  release: '%release%'\n  debug: '%debug%'";

    function Config(basepath) {
      this.basepath = basepath;
      this.write = __bind(this.write, this);

      this.create = __bind(this.create, this);

    }

    Config.prototype.create = function() {
      var q1, q2, q3,
        _this = this;
      q1 = "Path to your src folder? [src] : ";
      q2 = "Path to your release file? [www/js/app.js] : ";
      q3 = "Starting from your webroot '/', what's the folderpath to " + "reach your release file? (i.e. js) (optional) : ";
      return this.ask(q1.magenta, /.+/, function(src) {
        return _this.ask(q2.magenta, /.+/, function(release) {
          return _this.ask(q3.cyan, /.*/, function(httpfolder) {
            return _this.write(src, release, httpfolder);
          });
        });
      });
    };

    Config.prototype.write = function(src, release, httpfolder) {
      var buffer, filename, filepath, parts, question, rgx,
        _this = this;
      filepath = path.join(this.basepath, "toaster.coffee");
      rgx = /(\/)?((\w+)(\.*)(\w+$))/;
      parts = rgx.exec(release);
      filename = parts[2];
      if (filename.indexOf(".") > 0) {
        debug = release.replace(rgx, "$1$3-debug$4$5");
      } else {
        debug = "" + release + "-debug";
      }
      buffer = this.tpl.replace("%src%", src.replace(/\\/g, "\/"));
      buffer = buffer.replace("%release%", release.replace(/\\/g, "\/"));
      buffer = buffer.replace("%debug%", debug.replace(/\\/g, "\/"));
      buffer = buffer.replace("%httpfolder%", httpfolder.replace(/\\/g, "\/"));
      if (fs.existsSync(filepath)) {
        question = "\tDo you want to overwrite the file: " + filepath.yellow;
        question += " ? [y/N] : ".white;
        return this.ask(question, /.*?/, function(overwrite) {
          if (overwrite.match(/y/i)) {
            _this.save(filepath, buffer);
            return process.exit();
          }
        });
      } else {
        this.save(filepath, buffer);
        return process.exit();
      }
    };

    Config.prototype.save = function(filepath, contents) {
      fs.writeFileSync(filepath, contents);
      log("" + 'Created'.green.bold + " " + filepath);
      return process.exit();
    };

    return Config;

  })(toaster.generators.Question);

  __t('toaster.generators').Project = (function(_super) {
    var FsUtil, fs, fsu, path;

    __extends(Project, _super);

    path = require("path");

    fs = require("fs");

    fsu = require('fs-util');

    FsUtil = toaster.utils.FsUtil;

    function Project(basepath) {
      this.basepath = basepath;
      this.scaffold = __bind(this.scaffold, this);

    }

    Project.prototype.create = function(folderpath, name, src, release) {
      var error_msg, q1, q2, q3,
        _this = this;
      if ((typeof folderpath) !== 'string') {
        error_msg = "You need to inform a target path!\n";
        error_msg += "\ttoaster -n myawesomeapp".green;
        return error(error_msg);
      }
      if ((name != null) && (src != null) && (release != null)) {
        return this.scaffold(folderpath, name, src, release);
      }
      q1 = "Path to your src folder? [src] : ";
      q2 = "Path to your release file? [www/js/app.js] : ";
      q3 = "Starting from your webroot '/', what's the folderpath to " + "reach your release file? (i.e. js) (optional) : ";
      return this.ask(q1.magenta, /.*/, function(src) {
        if (src == null) {
          src = null;
        }
        return _this.ask(q2.magenta, /.*/, function(release) {
          if (release == null) {
            release = null;
          }
          return _this.ask(q3.cyan, /.*/, function(httpfolder) {
            var $httpfolder, $release, $src;
            if (httpfolder == null) {
              httpfolder = null;
            }
            $src = src || "src";
            $release = release || "www/js/app.js";
            if (src === '' && release === '' && httpfolder === '') {
              $httpfolder = 'js';
            } else {
              $httpfolder = httpfolder || "";
            }
            _this.scaffold(folderpath, $src, $release, $httpfolder);
            return process.exit();
          });
        });
      });
    };

    Project.prototype.scaffold = function(target, src, release, httpfolder) {
      var config, releasedir, releasefile, srcdir, vendorsdir;
      target = path.resolve(target);
      srcdir = path.join(target, src);
      vendorsdir = path.join(target, "vendors");
      releasefile = path.join(target, release);
      releasedir = path.dirname(releasefile);
      if (fsu.mkdir_p(target)) {
        log("" + 'Created'.green.bold + " " + target);
      }
      if (fsu.mkdir_p(srcdir)) {
        log("" + 'Created'.green.bold + " " + srcdir);
      }
      if (fsu.mkdir_p(vendorsdir)) {
        log("" + 'Created'.green.bold + " " + vendorsdir);
      }
      if (fsu.mkdir_p(releasedir)) {
        log("" + 'Created'.green.bold + " " + releasedir);
      }
      srcdir = srcdir.replace(target, "").substr(1);
      releasefile = releasefile.replace(target, "").substr(1);
      config = new toaster.generators.Config(target);
      return config.write(srcdir, releasefile, httpfolder);
    };

    return Project;

  })(toaster.generators.Question);

  fs = require('fs');

  path = require('path');

  exec = (require("child_process")).exec;

  __t('toaster.misc').InjectNS = (function() {

    function InjectNS(builders) {
      var builder, f, _i, _j, _len, _len1, _ref, _ref1;
      this.builders = builders;
      console.log("Declaring namespaces for files...");
      _ref = this.builders;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        builder = _ref[_i];
        _ref1 = builder.files;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          f = _ref1[_j];
          f.getinfo(true);
          fs.writeFileSync(f.realpath, f.raw);
          f.getinfo(false);
          console.log(f.realpath);
        }
      }
      console.log("...done.");
    }

    return InjectNS;

  })();

  exports.run = function(basedir, options, skip_initial_build) {
    if (options == null) {
      options = null;
    }
    if (skip_initial_build == null) {
      skip_initial_build = false;
    }
    return new Toaster(basedir, options, skip_initial_build);
  };

  exports.toaster = toaster;

  exports.Toaster = Toaster = (function() {
    var colors, fsu;

    fs = require("fs");

    fsu = require("fs-util");

    path = require("path");

    exec = (require("child_process")).exec;

    colors = require('colors');

    Toaster.basedir = null;

    Toaster.options = null;

    Toaster.skip_initial_build = false;

    Toaster.prototype.before_build = null;

    function Toaster(basedir, options, skip_initial_build) {
      var base, contents, filepath, flag, k, msg, schema, v, _i, _len, _ref, _ref1;
      if (options == null) {
        options = null;
      }
      if (skip_initial_build == null) {
        skip_initial_build = false;
      }
      this.basedir = basedir;
      this.options = options;
      this.skip_initial_build = skip_initial_build;
      this.basepath = path.resolve(basedir || ".");
      this.cli = new toaster.Cli(options);
      _ref = 'nicwd'.split('');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        flag = _ref[_i];
        if (typeof (base = this.cli.argv[flag]) === 'string') {
          this.basepath = path.resolve(base);
          break;
        }
      }
      if (this.options != null) {
        _ref1 = this.options;
        for (k in _ref1) {
          v = _ref1[k];
          this.cli.argv[k] = v;
        }
      }
      if (this.cli.argv.v) {
        filepath = path.join(__dirname, "/../package.json");
        contents = fs.readFileSync(filepath, "utf-8");
        schema = JSON.parse(contents);
        return log(schema.version);
      } else if (this.cli.argv.n) {
        new toaster.generators.Project(this.basepath).create(this.cli.argv.n);
      } else if (this.cli.argv.i) {
        new toaster.generators.Config(this.basepath).create();
      } else if (this.cli.argv.a && !this.cli.argv.c) {
        msg = "Option -a can't work without -w, usage: \n";
        msg += "\ttoaster -wa";
        error(msg);
      } else if (this.cli.argv.c || this.cli.argv.r || this.cli.argv.w) {
        this.toast = new toaster.Toast(this);
        if (!skip_initial_build) {
          this.build();
        }
      } else {
        return log(this.cli.opts.help());
      }
    }

    Toaster.prototype.build = function(header_code, footer_code) {
      var builder, _i, _len, _ref, _results;
      if (header_code == null) {
        header_code = "";
      }
      if (footer_code == null) {
        footer_code = "";
      }
      _ref = this.toast.builders;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        builder = _ref[_i];
        _results.push(builder.build(header_code, footer_code));
      }
      return _results;
    };

    Toaster.prototype.reset = function(options) {
      var builder, key, val, _i, _len, _ref;
      _ref = this.toast.builders;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        builder = _ref[_i];
        builder.reset();
      }
      if (options != null) {
        for (val in options) {
          key = options[val];
          this.options[key] = val;
        }
      }
      return exports.run(this.basedir, this.options, this.skip_initial_build);
    };

    return Toaster;

  })();

}).call(this);
