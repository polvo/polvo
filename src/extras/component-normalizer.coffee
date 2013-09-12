fs = require 'fs'
path = require 'path'

fsu = require 'fs-util'

dirs = require '../utils/dirs'
config = require '../utils/config'

components = []

folder = path.join dirs.pwd, 'components'
if fs.existsSync folder
  manifests = fsu.find folder, /component\.json/

  for manifest_path in manifests
    comp_folder = path.dirname manifest_path
    {name} = manifest = require manifest_path

    # creating component aliases
    config.alias[name] = dirs.relative comp_folder

    # fetching possible asset kinds
    kinds = 'styles scripts templates fonts files images'.split ' '
    for kind in kinds when manifest[kind]?
      for filepath in manifest[kind]
        abs = path.join comp_folder, filepath
        components.push abs

module.exports = components