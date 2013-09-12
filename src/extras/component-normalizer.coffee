fs = require 'fs'
path = require 'path'

fsu = require 'fs-util'

dirs = require '../utils/dirs'
config = require '../utils/config'

module.exports = ->
  components = path.join dirs.pwd, 'components'
  return unless fs.existsSync components
  manifests = fsu.find components, /component\.json/

  for manifest_path in manifests
    {name} = require manifest_path
    config.alias[name] = dirs.relative path.dirname manifest_path