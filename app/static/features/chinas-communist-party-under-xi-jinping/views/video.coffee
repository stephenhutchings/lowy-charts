require.register "views/video", (exports, require, module) ->
  keycode  = require("lib/keycode")

  class VideoView extends Backbone.View
    events:
      "enter": "enter"
      "exit": "exit"
      "click": "enter"
      "play": "toggle"
      "pause": "toggle"

    initialize: (@data) ->

    enter: ->
      if @el.paused
        @el.currentTime = 0 if @el.currentTime is @el.duration
        @el.play()#.catch(console.error)
      else
        @exit()

    exit: ->
      @el.pause()

    toggle: ->
      @$el.toggleClass("paused", @el.paused)


  module.exports = VideoView
