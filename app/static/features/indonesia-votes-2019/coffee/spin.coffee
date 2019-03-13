require.register "views/spin", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")

  dpi = window.devicePixelRatio or window.webkitDevicePixelRatio or 1
  red = "#f44336"
  black = "#1C0A13"

  class SpinView extends Backbone.View
    events:
      "show": "onShow"
      "hide": "onHide"

    initialize: ->
      { source } = @$el.data()

      @$canvas = $("<canvas class='svg-canvas' />")
      @context = @$canvas.get(0).getContext("2d")
      @$el.append @$canvas

      @onResize()

      @circles = require(source).map ({cx, cy, ring}) ->
        a = Math.atan2(cy, cx)
        d = Math.sqrt(Math.pow(cy, 2) + Math.pow(cx, 2))

        {
          cx, cy, ring, a, d
          ms: _.random(0, 900)
          fill: 0
        }

      @onHide()
      @listenTo(this, "resize", @onResize)

    onShow: ->
      return unless @$el.is(":visible")

      now = Date.now()
      dur = 2000

      @playing = true
      @$el.addClass("playing")
      fill = @$el.data("fill")

      do repeat = =>
        return unless @playing

        @context.clearRect(0, 0, @context.canvas.width, @context.canvas.height)

        w = @context.canvas.width
        h = @context.canvas.height
        x = (w / 2)
        y = (h / 2)

        y *= 0.8 if w < 300 * dpi and @el.firstChild

        r = 3 * dpi

        t = (Date.now() - now) / dur
        t = Math.min(t, 1)
        t = easie.quintOut(t)

        window.requestAnimationFrame(repeat)

        return if t is 0

        if t < 1
          @context.fillStyle = black

          for { a, d, ms }, i in @circles
            t = (Date.now() - now - ms) / (dur - ms)
            t = Math.max(Math.min(t, 1), 0)
            t = easie.quintInOut(t)

            cx = Math.cos(a + Math.PI * (1 - t)) * (d + 100 * (1 - t))
            cy = Math.sin(a + Math.PI * (1 - t)) * (d + 100 * (1 - t))

            cx *= dpi
            cy *= dpi

            @context.globalAlpha = t
            @context.beginPath()
            @context.moveTo(x + cx + r, y + cy)
            @context.arc(x + cx + r, y + cy, r, 0, Math.PI * 2, 0)
            @context.fill()

        else
          for { a, d, ms, ring }, i in @circles
            o = ring * 2000
            t = ((Date.now() - dur - now) / (20000 + o)) % 1
            t = easie.sineInOut(t)

            cx = Math.cos(a - Math.PI * 2 * t) * d
            cy = Math.sin(a - Math.PI * 2 * t) * d

            cx *= dpi
            cy *= dpi

            @circles[i].cx = cx
            @circles[i].cy = cy

          nb = (fill or -1) * @circles.length

          for c, i in _.sortBy(@circles, "cy").reverse()
            s = i <= nb
            c.fill += ((if s then 1 else -1) * 0.05)
            c.fill = Math.max(Math.min(c.fill, 1), 0)

          @context.globalAlpha = 1
          @context.fillStyle = black
          @context.beginPath()

          for c in @circles when c.fill < 1
            @context.moveTo(x + c.cx + r, y + c.cy)
            @context.arc(x + c.cx + r, y + c.cy, r, 0, Math.PI * 2, 0)

          @context.fill()

          for c in @circles when c.fill > 0
            @context.beginPath()
            @context.moveTo(x + c.cx + r, y + c.cy)
            @context.arc(x + c.cx + r, y + c.cy, r, 0, Math.PI * 2, 0)
            @context.globalAlpha = c.fill
            @context.fillStyle = red
            @context.fill()

    onHide: ->
      return unless @$el.is(":visible")

      @playing = false
      @$el.removeClass("playing")

      c.fill = 0 for c in @circles

      @context.clearRect(0, 0, @context.canvas.width, @context.canvas.height)

    onResize: ->
      w = @$el.width()
      h = @$el.height()

      @context.canvas.width  = w * dpi
      @context.canvas.height = h * dpi

  module.exports = SpinView
