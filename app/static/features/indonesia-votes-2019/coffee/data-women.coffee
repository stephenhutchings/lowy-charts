require.register "data/women", (exports, require, module) ->
  module.exports = require("data/votes").slice(0, 157)
