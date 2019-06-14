require.register "views/bars", (exports, require, module) ->
  easie = require("lib/easie")

  class BarsView extends Backbone.View
    events:
      "enter": "enter"
      "exit": "exit"

    initialize: (@data) ->
      @$elements =
        val: @$(".bar-value")
        bar: @$(".bar-bg")

      @data.suffix ?= ""
      @data.direction ?= 1

    enter: ->
      now = Date.now() + @data.delay

      @$el.removeClass("complete playing")

      do repeat = =>
        d = Date.now() - now
        t = d / (@data.duration + @data.delay)
        tx = easie.quintInOut Math.max(Math.min(t, 1), 0)

        if @data.value
          @$elements.val.html((tx * @data.value).toFixed(1) + @data.suffix)
          @$elements.bar.css(transform: "translate3d(#{(-1 + tx) * 100 * @data.direction}%,0,0)")

        if t > 0
          @$el.addClass("playing")

        if t < 1
          @loop = window.requestAnimationFrame(repeat)
        else
          @$el.removeClass("playing").addClass("complete")

    exit: ->
      window.cancelAnimationFrame(@loop)
      @$el.removeClass("complete playing")
      @$elements.val.html(@data.value)
      @$elements.bar.css(transform: "translate3d(#{100 * -@data.direction}%,0,0)")


  module.exports = BarsView
