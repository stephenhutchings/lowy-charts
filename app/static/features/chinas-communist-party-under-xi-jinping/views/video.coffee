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
      $(window).on "keydown", _.bind(@onKeyPress, this)

    enter: ->
      @active = true

    exit: ->
      @active = false
      @el.pause()

    onKeyPress: (e) ->
      if @active
        code = keycode(e)
        if code is "DOWN" or code is "RIGHT"
          if @el.paused
            e.preventDefault()
            e.stopImmediatePropagation()
            @el.play()
        else if code is "UP" or code is "LEFT"
          if not @el.paused
            e.preventDefault()
            e.stopImmediatePropagation()
            @el.pause()

      return true

    toggle: ->
      @$el.toggleClass("paused", @el.paused)


  module.exports = VideoView
