module.exports = cli;

function cli() {

  var commands = {},
      options = {},
      backup = null;

  function next_params (list) {
    var op = [];
    if(!list || !list.length) return op;

    while(true) {
      if( list.length && !~list[0].indexOf('--') )
        op.push(list.shift());
      else
        return op;
    }
  }

  return {
    command: null,
    params: [],
    options: {},

    cmd: function(name, desc, usage) {
      commands[name] = {desc: desc, usage: usage};
      return this;
    },

    opt: function(name, desc, type, usage) {
      options[name] = {desc:desc, type:type, usage: usage};
      return this;
    },

    parse: function(argv) {
      if(argv.length > 2)
        if(~argv[2].indexOf('--')) {
          parser = this.parse_args(argv.slice(2));
          this.command = null;
        }
        else {
          this.command = argv[2].replace(/^\s*|\s*$/g, '');
          parser = this.parse_args(argv.slice(3));
        }

      return {
        params: this.params,
        options: this.options,
        command: this.command
      };
    },

    parse_args: function(list) {
      if(list.length === 0) return;

      var name, next, opt = list.shift();

      if( opt && ~opt.indexOf('--') ) {

        name = opt.slice(2).replace(/\-/g, '_');
        next = next_params(list);

        if(next.length === 0)
          this.options[name] = true;

        else if(next.length == 1)
          this.options[name] = next[0];

        else
          this.options[name] = next;
      } else {
        this.params.push(opt);
      }

      if(list.length)
        this.parse_args(list);

      return true;
    },

    usage: function () {
      var len
    }
  };

}