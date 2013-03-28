uglify = require("uglify-js").uglify
uglify_parser = require("uglify-js").parser

module.exports = class MinifyUtil
  @min:( contents )->
    ast = uglify_parser.parse contents
    ast = uglify.ast_mangle ast
    ast = uglify.ast_squeeze ast
    compiled = uglify.gen_code ast