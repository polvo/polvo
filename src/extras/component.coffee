fs = require 'fs'
path = require 'path'

fsu = require 'fs-util'

dirs = require '../utils/dirs'
config = require '../utils/config'

module.exports = components = []

# - walk up dir tree searching for some `component.json` manifest file
# - if manifest is found, checks for a sibling `components` folder
# - if found, search for every `component.json` manifes file inside of it
# - returns the found manifests or an empty array
find_manifests = ->
  base = path.join dirs.pwd
  
  while base isnt '/'
    manifest = path.join base, 'component.json'

    if fs.existsSync manifest
      components_folder = path.join base, 'components'
      if fs.existsSync components_folder
        manifests = fsu.find components_folder, /component\.json/
        return manifests

    base = path.join base, '..'

  return []

manifests = find_manifests()

# registers all components with aliases
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