require.register "views/line", (exports, require, module) ->
  easie = require("lib/easie")
  interpolate = (x, y, p) ->
    [
      x[0] + (y[0] - x[0]) * p
      x[1] + (y[1] - x[1]) * p
    ]

  class LineView extends Backbone.View
    events:
      "enter": "enter"
      "exit": "exit"

    initialize: (@data) ->
      @data.duration ?= 2000
      @data.delay ?= 0

      @lines = ({$el: $(el)} for el in @$(".line").toArray())

      for line in @lines
        line.points = line.$el.attr("points").split(" ").map((e) -> e.split(",").map(parseFloat))

      @exit()


    enter: ->
      now = Date.now() + @data.delay
      @playing = true

      @$el.removeClass("complete playing")

      do repeat = =>
        d = Date.now() - now
        t = d / (@data.duration + @data.delay)
        t = easie.sineInOut Math.max(Math.min(t, 1), 0)

        for line in @lines
          k = t * (line.points.length - 1)
          x = Math.floor(k)
          y = Math.min(x + 1, line.points.length)
          p = k - x

          pts = line.points.slice(0, y)

          if x < line.points.length - 1
            pts.push(interpolate(line.points[x], line.points[y], p))

          line.$el.attr("points", pts.map((v) => v.join(",")).join(" "))

        if t > 0 and @playing
          @$el.addClass("playing")

        if t < 1 and @playing
          @loop = window.requestAnimationFrame(repeat)
        else if @playing
          @$el.removeClass("playing").addClass("complete")
          @playing = false
          @stopListening()
          @undelegateEvents()

    exit: ->
      @playing = false
      @$el.removeClass("complete playing")


  module.exports = LineView
