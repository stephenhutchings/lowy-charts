require.register "views/my-view", (exports, require, module) ->
  module.exports =
    class MyView extends Backbone.View
      initialize: ->
        alert 'hi'
        console.log 'hi'
        #not working ?
