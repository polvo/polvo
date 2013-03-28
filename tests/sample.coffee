# ...
# requirements
fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'

# ...
# outputting version
version = fs.readFileSync (path.join __dirname, '../package.json'), 'utf-8'
console.log '\nCurrent version is: ' + (JSON.parse version).version

# ...
# sample
describe '• Sample Test', ->
  # ...
  # 1) empty test sample
  describe 'An empty test', ->
    it 'will always be ok.', ->
      true.should.equal true