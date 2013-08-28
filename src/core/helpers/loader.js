function require(path, parent){
  var m, realpath;

  if(parent)
  {
    realpath = require.mods[parent].aliases[path];
    if(!realpath) realpath = require.virtual( path );
  }
  else
    realpath = path;

  if(!(m = require.mods[realpath]))
    return console.error('Module not found: ', path);

  if(!m.init)
  {
    m.factory.call(this, require.local(realpath), m.module, m.module.exports);
    m.init = true;
  }

  return m.module.exports;
}

require.mods = {}

require.local = function( path ){
  return function( id ) { return require( id, path ); }
}

require.register = function(path, mod, aliases){
  require.mods[path] = {
    factory: mod,
    aliases: aliases,
    module: {exports:{}}
  };
}

require.virtual = function(path) {
  for(var virtual in require.virtual.conf)
    if(path.indexOf(virtual) == 0)
      return require.virtual.conf[virtual] + path.match(/\/(.+)/)[0];
  return null;
}

require.virtual.conf = ~VIRTUAL;