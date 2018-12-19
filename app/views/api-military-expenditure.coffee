easie = require("lib/easie")

interpolate = (x, y, p) -> Math.round x + (y - x) * p
toThousands = (n) -> n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

module.exports =
  class Chart extends Backbone.View
    data: window.chart

    events:
      "click #btn-play": "play"
      "click #btn-pause": "pause"
      "click #btn-reset": "reset"

    initialize: ->
      @$elements =
        country: @$(".country")
        blocks:  @$(".country-bar-block")
        labels:  @$(".country-bar-label")
        year:    @$(".year")
        years:   @$("#axis-years-list")

      @config =
        barH: @$elements.country.outerHeight()
        barW: @$elements.country.outerWidth()

      @reset()

    render: (t) ->
      x = Math.floor(t)
      y = Math.min(x + 1, @data.years.length - 1)
      p = t - x

      list = _.chain(@data.countries)
        .map(({ name, data }, index) ->
          { name, index, value: interpolate(data[x], data[y], p) }
        )
        .sortBy("value")
        .reverse()
        .value()

      max = _.chain(list).pluck("value").max().value()
      min = _.chain(list).pluck("value").min().value()

      @$elements.year.removeClass("active").eq(Math.round(t)).addClass("active")
      @$elements.years.css transform: "translate3d(0, #{-t * 100}%, 0)"

      for { value, index }, rank in list
        @$elements.blocks.eq(index).css
          transform: "translate3d(#{-100 + value / max * 100}%, 0, 0)"

        @$elements.country.eq(index).css
          transform: "translate3d(0, #{rank * @config.barH}px, 0)"

        @$elements.labels.eq(index).html "$#{toThousands(value)}M"

    play: (reset) ->
      window.cancelAnimationFrame(@loop)

      @playing = true

      @$el.addClass("playing")

      @currentTime ?= 0
      max = @data.years.length - 1
      dur = 2500 * max
      now = Date.now() - @currentTime * dur

      do repeat = =>
        d = Date.now() - now
        t = d / dur
        t = Math.min(t, 1)

        @currentTime = t
        @render(easie.sineInOut(t) * max)

        if t < 1 and @playing
          @loop = window.requestAnimationFrame(repeat)
        else if @playing
          @$el.removeClass("playing")
          @currentTime = 0
          @playing = false

    pause: ->
      if @playing
        @playing = false
        @$el.removeClass("playing")
      else
        @play()

    reset: (e) ->
      @currentTime = 0
      @$el.removeClass("playing")
      @render(0)
      window.setTimeout (=> @play(true)), if @playing then 0 else 600
