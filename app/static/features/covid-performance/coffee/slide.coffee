require.register "views/slide", (exports, require, module) ->
  easie = require("lib/easie")

  class SlideView extends Backbone.View
    events:
      "enter": "enter"
      "exit": "exit"
      "setup": "setup"

    initialize: (@data) ->
      @data.duration ?= 2000
      @data.delay ?= 0

    setup: ->
      return if @hasRun
      @hasRun = true

      @lines = ({$el: $(el)} for el in @$(".line").toArray())
      offset = 0

      for line in @lines
        line.text = line.$el.text()
        line.width = ~~line.$el.width()
        line.offset = offset
        line.$el.width(line.width)
        line.$el.html """<span class="mask">#{line.text}</span>"""
        offset += line.text.length

      @exit()

    enter: ->
      return unless @lines

      pause = 300
      now = Date.now() + @data.delay
      total = @lines.reduce ((m, e)-> m + e.text.length), 0

      line.$el.addClass("hide") for line in @lines

      do repeat = =>
        d = Date.now() - now

        for line, i in @lines
          del = @data.delay + i * pause
          dur = @data.duration - (@lines.length - 1) * pause
          ol = -18
          x = line.offset / total
          t = (d - del) / (dur)
          t = easie.quintInOut Math.max(Math.min(t, 1), 0)
          line.$el.children().width(t * line.width)
          line.$el.removeClass("hide") if t > 0

        if t > 0
          @$el.addClass("playing")

        if t < 1 and
          @loop = window.requestAnimationFrame(repeat)
        else
          @$el.removeClass("playing complete")

    exit: ->
      return unless @lines
      window.cancelAnimationFrame(@loop)
      @$el.removeClass("playing complete")
      line.$el.addClass("hide") for line in @lines


  module.exports = SlideView
