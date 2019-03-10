require.register "views/svg", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")

  class SvgView extends Backbone.View
    events:
      "show": "onShow"
      "hide": "onHide"

    initialize: ->
      $svg = @$("svg")
      w = $svg.outerWidth()
      h = $svg.outerHeight()

      $svg
        .attr("height", "#{Math.round h}px")
        .attr("width", "#{Math.round w}px")
        .attr("viewBox", "#{-w/2} #{-h/2} #{w} #{h}")

      @$circles = @$("circle").map(->
        cx = parseFloat this.attributes.cx.value
        cy = parseFloat this.attributes.cy.value
        a = Math.atan2(cy, cx)
        d = Math.sqrt(Math.pow(cy, 2) + Math.pow(cx, 2))
        $(this).css("transition", "fill 600ms")

        {
          $el: $(this), a, d
          ms: _.random(0, 900)
        }

      ).toArray()

      @onHide()

    onShow: ->
      now = Date.now()
      dur = 2000

      @playing = true
      @$el.addClass("playing")
      fill = @$el.data("fill")

      do repeat = =>
        return unless @playing

        t = (Date.now() - now) / dur
        t = Math.min(t, 1)
        t = easie.quintOut(t)

        window.requestAnimationFrame(repeat)

        if t < 1
          for { $el, a, d, ms }, i in @$circles
            t = (Date.now() - now - ms) / (dur - ms)
            t = Math.min(t, 1)
            t = easie.quintInOut(t)

            $el.attr
              "cx": Math.cos(a + Math.PI * (1 - t)) * (d + 100 * (1 - t))
              "cy": Math.sin(a + Math.PI * (1 - t)) * (d + 100 * (1 - t))
              "fill-opacity": t

        else
          for { $el, a, d, ms }, i in @$circles
            o = $el.data("ring") * 2000
            t = ((Date.now() - dur - now) / (20000 + o)) % 1
            t = easie.sineInOut(t)

            @$circles[i].cx = Math.cos(a - Math.PI * 2 * t) * d
            @$circles[i].cy = Math.sin(a - Math.PI * 2 * t) * d

            $el.attr
              "cx": @$circles[i].cx
              "cy": @$circles[i].cy
              "fill-opacity": 1

          if fill
            for { $el }, i in _.sortBy(@$circles, "cy").reverse()
              if i < @$circles.length * fill
                $el.attr("fill", "#fc5839")
              else
                $el.attr("fill", "")

    onHide: ->
      @playing = false
      @$el.removeClass("playing")

      for { $el, a, d } in @$circles
        $el.attr
          "fill-opacity": 0

  module.exports = SvgView
