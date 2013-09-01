# clear cache between all tests

afterEach ->
  mods = [
    '../../lib/utils/plugins'
    '../../lib/core/compiler'
    '../../lib/core/file'
    '../../lib/core/files'
    '../../lib/core/server'

    '../../lib/scanner/resolve'
    '../../lib/scanner/scan'
  ]

  for m in mods
    mod = require.resolve m
    delete require.cache[mod]