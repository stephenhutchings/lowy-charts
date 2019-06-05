require.register "views/bars", (exports, require, module) ->
  easie = require("lib/easie")

  class BarsView extends Backbone.View
    events:
      "enter": "enter"
      "exit": "exit"

    initialize: (@data) ->
      @$value = @$(".bar-value")
      @data.suffix ?= ""
      @exit()

    enter: ->
      now = Date.now() + @data.delay

      @$el.removeClass("complete playing")

      do repeat = =>
        d = Date.now() - now
        t = d / (@data.duration + @data.delay)
        tx = easie.quintInOut Math.max(Math.min(t, 1), 0)

        if @data.value
          @$value.html((tx * @data.value).toFixed(1) + @data.suffix)
          @$el.width(tx * @data.width + "%")

        if t > 0
          @$el.addClass("playing")

        if t < 1
          @loop = window.requestAnimationFrame(repeat)
        else
          @$el.removeClass("playing").addClass("complete")

    exit: ->
      window.cancelAnimationFrame(@loop)
      @$el.removeClass("complete playing")
      @$value.html("")
      @$el.width(0)


  module.exports = BarsView
