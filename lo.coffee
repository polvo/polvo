_ = require 'lodash'

class File
  type: null

  constructor:(@type)->

files = [
  new File 'js'
  new File 'css'
  new File 'js'
  new File 'js'
]

found = _.filter files, type: 'js'
console.log found