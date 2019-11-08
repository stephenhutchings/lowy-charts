require.register "views/gdp-vs-me", (exports, require, module) ->
  easie = require("lib/easie")
  interpolate = (x, y, p) -> if x >= 0 and y >= 0 then x + (y - x) * p

  class CustomView extends Backbone.View
    data: window.chart

    events:
      "click #btn-play": "play"
      "click #btn-pause": "pause"
      "click #btn-reset": "reset"
      "click #btn-end": "end"
      "click .year-link": "goToYear"
      "chartplay": "pause"
      "chartpause": "pause"
      "chartreset": "reset"

    initialize: ->
      @$elements =
        countries: @$("#countries")
        country: @$(".country")
        label:   @$(".country-label")
        year:    @$(".year")
        years:   @$("#axis-years-list")
        keys:    @$(".chart-title-label")

      @values =
        _.chain(@data.countries)
        .map((country, index) =>
          {
            name: country.name
            index
            values: for year, i in @data.scale
              100 - country.me[i] / 1400  * 100
          }
        )
        .value()

      @reset()
      window.setTimeout (=> @play()), 600

    render: (t) ->
      x = Math.floor(t)
      y = Math.min(x + 1, @data.scale.length - 1)
      p = t - x

      width  = @$elements.countries.width()
      height = @$elements.countries.height()

      @$elements.year
        .removeClass("active")
        .eq(Math.round(t))
        .addClass("active")

      match = false
      for key in _.keys(@data.classes).reverse()
        t1  = easie.sineInOut(parseFloat(key)) * (@data.scale.length - 1)
        val = @data.classes[key]
        @$el.toggleClass(val, not(match) and t >= t1)
        match = match or t >= t1

      @$elements.years.css transform: "translate3d(0, #{-t * 100}%, 0)"

      for { name, values, index }, j in @values
        $el = @$elements.country.eq(index)
        cy = interpolate(values[x], values[y], p)

        if t is 0
          pts = ""
        else
          pts = values
            .slice(0, y)
            .concat(cy)
            .map((v, i) =>
              "#{(Math.min(i, t) / (@data.scale.length)) * 100},#{v}"
            )
            .join(" ")

        $el.attr("points", pts)

        @$elements.label.eq(index).css(
          transform: "translate3d(#{t / (@data.scale.length) * 100}%, #{cy}%, 0)"
        ).children().first().html(@data.countries[index].rel[x])


    play: ->
      window.cancelAnimationFrame(@loop)

      @playing = true

      @$el.addClass("playing")

      if @currentTime is 1 or not @currentTime?
        @currentTime = 0

      max = @data.scale.length - 1
      now = Date.now() - @currentTime * @data.duration

      do repeat = =>
        d = Date.now() - now
        t = d / @data.duration
        t = Math.min(t, 1)

        @render(easie.sineInOut(t) * max)

        if t < 1 and @playing
          @currentTime = t
          @loop = window.requestAnimationFrame(repeat)
        else if @playing
          @$el.removeClass("playing")
          @currentTime = 1
          @playing = false

    pause: ->
      if @playing
        @playing = false
        @$el.removeClass("playing")
      else
        @play()

    reset: (e) ->
      window.cancelAnimationFrame(@loop)
      @currentTime = 0
      @$el.removeClass("playing")
      @render(0)

    end: ->
      t = @data.scale.length - 1
      window.setTimeout (=> @render(t)), if @playing then 100 else 0
      @currentTime = 1
      @playing = false
      @$el.removeClass("playing")

    goToYear: (e) ->
      r = (t) -> (Math.acos(-2 * t + 1)) / Math.PI
      n = (@data.scale.length - 1)
      t = @$(e.currentTarget).data("index") / n
      @currentTime = r(t)
      console.log @currentTime
      @playing = false
      @$el.removeClass("playing")
      window.setTimeout (=>
        @render(t * n)
      ), 100

    module.exports = CustomView
