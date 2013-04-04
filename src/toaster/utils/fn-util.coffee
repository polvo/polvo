require('source-map-support').install()

module.exports = class FnUtil
  @proxy:(fn, params...)->
    ( inner_params... )->
      fn.apply null,  params.concat inner_params