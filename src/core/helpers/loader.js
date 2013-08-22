function require(path, parent){
  var m, realpath;

  if(parent)
    realpath = require.mods[parent].aliases[path];
  else
    realpath = path;

  if(!realpath)
    realpath = require.map( path );
  
  if(!(m = require.mods[realpath]))
  {
    console.error('Module not found: ', path);
    return null
  }
  
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

require.maps = ~MAPPINGS;
require.map = function(path) {
  for(var map in require.maps)
    if(path.indexOf(map) == 0)
      return require.maps[map] + path;
  return null;
}