easie = require("lib/easie")

interpolate = (x, y, p) -> if x >= 0 and y >= 0 then Math.round x + (y - x) * p
toThousands = (n) -> n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

module.exports =
  class Chart extends Backbone.View
    data: window.chart

    events:
      "click #btn-play": "play"
      "click #btn-pause": "pause"
      "click #btn-reset": "reset"
      "click #btn-end": "end"
      "click .year-link": "goToYear"

    initialize: ->
      @$elements =
        blocks:  {}
        country: @$(".country")
        labels:  @$(".country-bar-label")
        year:    @$(".year")
        years:   @$("#axis-years-list")
        scale:   @$("#scale-strokes")
        strokes: @$(".scale-stroke")

      for key in @data.keys
        @$elements.blocks[key] = @$(".country-bar-block.#{key}")

      @reset()
      window.setTimeout (=> @play()), 600

    render: (t) ->
      x = Math.floor(t)
      y = Math.min(x + 1, @data.scale.length - 1)
      p = t - x

      lists =
        for key in @data.keys
          _.chain(@data.countries)
          .map((country, index) =>
            {
              name: country.name
              index
              isEstimate: @data.scale[x] >= country.after
              value: interpolate(country[key][x], country[key][y], p)
            })
          .sortBy((c) -> if c.value? then -c.value else Infinity)
          .value()

      list = lists[0]
      max = _.chain(lists).flatten().pluck("value").max().value()

      length = @$elements.strokes.length

      factor = @data.scaleFactor / (1 / length)
      scale  = factor / max

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

      @$elements.years.css   transform: "translate3d(0, #{-t * 100}%, 0)"
      @$elements.scale.css   transform: "scale3d(#{scale}, 1, 1)"
      @$elements.strokes.css transform: "scale3d(#{1 / scale}, 1, 1)"

      for l, i in lists
        key = @data.keys[i]
        for { value, index }, rank in l
          value ?= 0
          @$elements.blocks[key].eq(index).css
            transform: "translate3d(#{-100 + value / max * 100}%, 0, 0)"

      for { value, index, isEstimate }, rank in list
        @$elements.country.eq(index)
          .toggleClass("estimate", isEstimate)
          .css
            transform: "translate3d(0, #{Math.min(rank, 25) * 100}%, 0)"
            opacity: 1

        if rank < 25
          @$elements.labels.eq(index).html(
            if value
              [@data.prefix, toThousands(value), @data.suffix].join("")
            else
              "No Data"
          )
        else
          @$elements.country.eq(index).css opacity: 0

    play: ->
      window.cancelAnimationFrame(@loop)

      @playing = true

      @$el.addClass("playing")

      @currentTime ?= 0
      max = @data.scale.length - 1
      now = Date.now() - @currentTime * @data.duration
      console.log @currentTime

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
          @currentTime = 0
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
      @playing = false
      @$el.removeClass("playing")

    goToYear: (e) ->
      # -.5 * (m.cos(m.PI * t) - 1)
      r = (t) -> (Math.acos(-2 * t + 1)) / Math.PI
      n = (@data.scale.length - 1)
      t = @$(e.currentTarget).data("index") / n
      console.log t, r(t)
      @currentTime = r(t)
      @playing = false
      @$el.removeClass("playing")
      window.setTimeout (=>
        @render(t * n)
      ), 100
