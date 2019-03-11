require.register "views/spiral", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")

  class SpiralView extends Backbone.View
    events:
      "show": "onShow"
      "hide": "onHide"

    initialize: ->
      $svg = @$("svg")

      @onResize()

      @$circles = @$("circle").map(->
        $el = $(this)
        cx = parseFloat this.attributes.cx.value
        cy = parseFloat this.attributes.cy.value

        $el.css("transition", "fill 600ms")
        $el.attr("opacity", "0") if $el.index() is 0

        {
          $el, original: { cx, cy }
          group: $el.parent().index()
        }

      ).toArray()

      @onHide()
      @listenTo(this, "resize", @onResize)

    onShow: ->
      now = Date.now()

      groups = _.groupBy(@$circles, "group")
      group.reverse() for id, group of groups

      duration = 1000
      delay = duration / _.size(groups)

      @playing = true
      @$el.addClass("playing")
      fill = @$el.data("fill")

      do repeat = =>
        return unless @playing

        window.requestAnimationFrame(repeat)

        for id, group of groups
          j = parseInt(id)
          for { $el, ms, original }, i in group
            t = ((Date.now() - now) / (duration * 2 - j * delay)) % 1

            next = group[i + 1]?.original

            if next
              group[i].cx = original.cx + (next.cx - original.cx) * t
              group[i].cy = original.cy + (next.cy - original.cy) * t
              opacity =
                if i is 0 then t
                else if i is group.length - 2 then 1 - t
                else 1

              $el.attr
                "cx": group[i].cx
                "cy": group[i].cy
                "opacity": opacity

    onHide: ->
      @playing = false
      @$el.removeClass("playing")

      for { $el, original } in @$circles
        $el.attr
          "cx": original.cx
          "cy": original.cy

    onResize: ->
      $svg = @$("svg")

      w = $svg.outerWidth()
      h = $svg.outerHeight()

      $svg
        .attr("height", "#{Math.round h}px")
        .attr("width", "#{Math.round w}px")
        .attr("viewBox", "#{-w/2} #{-h/2} #{w} #{h}")

  module.exports = SpiralView
