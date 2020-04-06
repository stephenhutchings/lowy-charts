# This view animates the number counting up based on the HTML content, which
# is assumed to be a number.

require.register "views/counter", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")

  class CounterView extends Backbone.View
    events:
      "show": "onShow"
      "hide": "onHide"

    initialize: ->
      html = @$el.html()

      @$el.html (
        html.replace(/(\d)/g, "<span class='digit' data-value='$1'>0</span>")
      )

      @$digits = @$("span").map(-> $(this)).toArray()
      fs = parseInt @$el.css("font-size")

      for $el, i in @$digits
        val = parseInt $el.data("value")
        y   = val * 10 + i * 300

        $el.attr("data-y", -y).width($el.width() / fs + "em").html """
          <ul>
            <li>0</li><li>1</li><li>2</li><li>3</li><li>4</li>
            <li>5</li><li>6</li><li>7</li><li>8</li><li>9</li><li>0</li>
          </ul>
        """

        $el.find("li").eq(val).addClass("active")

      @onHide()

    onShow: ->
      now = Date.now()
      dur = 1500

      @playing = true
      @$el.addClass("playing")

      do repeat = =>
        return unless @playing

        t = (Date.now() - now) / dur
        t = Math.min(t, 1)

        if t < 1
          window.requestAnimationFrame(repeat)
        else
          @$el.removeClass("playing")

        for $el, i in @$digits
          ms = (@$digits.length - i) * 100
          t = (Date.now() - now - ms) / (dur - ms)
          t = Math.max(Math.min(t, 1), 0)
          y = easie.quintInOut(t) * $el.data("y") % 100
          $el.children().first().css("transform": "translate3d(0, #{y}%, 0)")

    onHide: ->
      @playing = false
      $el.children().first().css("transform": "") for $el, i in @$digits
      @$el.removeClass("playing")

  module.exports = CounterView
