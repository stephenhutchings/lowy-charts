require.register "views/spiral", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")

  dpi = window.devicePixelRatio or window.webkitDevicePixelRatio or 1
  red = "#f44336"
  black = "#1C0A13"

  class SpiralView extends Backbone.View
    events:
      "show": "onShow"
      "hide": "onHide"

    initialize: ->
      { source } = @$el.data()

      @$canvas = $("<canvas class='svg-canvas' />")
      @context = @$canvas.get(0).getContext("2d")
      @$el.append @$canvas

      @listenTo(this, "resize", @onResize)

      @circles = require(source).map (el) ->
        _.extend {
          original: { cx: el.cx, cy: el.cy }
        }, el

      @onResize()
      @onShow()

    onShow: (e) ->
      return unless @$el.is(":visible")

      now = Date.now()

      groups = _.groupBy(@circles, "set")
      group.reverse() for id, group of groups

      duration = 600
      delay = duration / _.size(groups)


      @playing = true
      @$el.addClass("playing")
      fill = @$el.data("fill")

      do repeat = =>
        return unless @playing

        w = @context.canvas.width
        h = @context.canvas.height
        x = (w / 2)
        y = (h / 2)

        window.requestAnimationFrame(repeat) if e?

        @context.clearRect(0, 0, w, h)

        for id, group of groups
          j = parseInt(id)
          for el, i in group
            t = ((Date.now() - now) / (duration * 2 - j * delay)) % 1

            next = group[i + 1]?.original

            if next
              el.cx = el.original.cx + (next.cx - el.original.cx) * t
              el.cy = el.original.cy + (next.cy - el.original.cy) * t

            el.cx *= dpi
            el.cy *= dpi

            n = 8

            r =
              if i is 0 then t
              else if i is group.length - 2 then 1 - t
              else 1

            l = 1
            l = (i + t) / n if i < n
            l = ((-i + group.length) + (1 - t)) / n if i > group.length - n
            l = Math.pow(l, 0.8)

            el.r = r * l * 3 * dpi

        @context.beginPath()

        for { cx, cy, r } in @circles
          @context.moveTo(x + cx + r, y + cy)
          @context.arc(x + cx + r, y + cy, r, 0, Math.PI * 2, 0)

        @context.fill()


    onHide: ->
      return unless @$el.is(":visible")

      @playing = false
      @$el.removeClass("playing")

    onResize: ->
      w = @$el.width()
      h = @$el.height()

      @context.canvas.width  = w * dpi
      @context.canvas.height = h * dpi

  module.exports = SpiralView
