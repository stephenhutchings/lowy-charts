easie = require("lib/easie")

interpolate = (x, y, p) -> if x >= 0 and y >= 0 then x + (y - x) * p
toThousands = (n) -> Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

module.exports =
  class Chart extends Backbone.View
    data: window.chart

    events:
      "click #btn-play": "play"
      "click #btn-pause": "pause"
      "click #btn-reset": "reset"
      "click #btn-end": "end"
      "click .year-link": "goToYear"
      "click .chart-title-label": "selectKey"

    initialize: (opts) ->
      if opts.items
        @data.items = @data[opts.items]

      @$elements =
        blocks:  {}
        labels:  {}
        item:    @$(".item")
        year:    @$(".year")
        years:   @$("#axis-years-list")
        scale:   @$("#scale-strokes")
        strokes: @$(".scale-stroke")
        keys:    @$(".chart-title-label")

      for key in @data.keys
        @$elements.blocks[key] = @$(".item-bar-block.#{key}")
        @$elements.labels[key] = @$(".item-bar-label.#{key}")

      @selectKey()

      @$el.addClass("loading")
      @reset()

      window.setTimeout (=>
        @play()
        @$el.removeClass("loading")
      ), 600

    render: (t) ->
      x = Math.floor(t)
      y = Math.min(x + 1, @data.scale.length - 1)
      p = t - x

      lists =
        for key in @data.keys
          _.chain(@data.items)
          .map((item, index) =>
            {
              name: item.name
              index
              isEstimate: @data.scale[x] >= item.after
              value: interpolate(item[key][x], item[key][y], p)
              stack: @data.keys.reduce( (m, k) =>
                m + interpolate(item[k][x], item[k][y], p)
              , 0)
            })
          .sortBy((c) =>
            if @data.stack
              -c.stack
            else
              if c.value? then -c.value else Infinity
          )
          .value()

      list = lists[@activeIndex]
      max = _.chain(lists).flatten().pluck("value").max().value()

      if @data.stack
        max = _.max(
          lists[0]
            .map((e, i) ->
              val = e.value
              for list in lists.slice(1)
                val += list[i].value
              return val
            )
          )

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


      transforms = []

      for l, i in lists
        key = @data.keys[i]
        for { value, index }, rank in l
          value ?= 0
          pvalue = value

          if @data.stack
            transforms[rank] ?= 0
            pvalue += transforms[rank]
            transforms[rank] += pvalue

          pct    = pvalue / max
          strlen = Math.round(value).toString().length
          @$elements.blocks[key].eq(index).css(
            transform: "translate3d(#{-100 + pct * 100}%, 0, 0)"
          )

          if rank < @data.limit
            @$elements.labels[key].eq(index).html(
              if value >= 0
                [@data.prefix, toThousands(value), @data.suffix].join("")
              else
                "No Data"
            ).css(
              opacity:
                if i is 0
                  (pct * 100 - (strlen + 2))
                else
                  2 * (value - _.find(lists[0], {index}).value) / value
            )

      for { value, index, isEstimate }, rank in list
        @$elements.item.eq(index)
          .toggleClass("estimate", isEstimate)
          .css
            transform: "translate3d(0, #{Math.min(rank, @data.limit) * 100}%, 0)"
            opacity: 1

        if rank >= @data.limit
          @$elements.item.eq(index).css opacity: 0

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
      @playing = false
      @$el.removeClass("playing")
      window.setTimeout (=>
        @render(t * n)
      ), 100

    selectKey: (e) ->
      @activeIndex = if e then @$(e.currentTarget).index() else 0
      @$elements.keys.removeClass("active").eq(@activeIndex).addClass("active")

      if not @playing
        @render(easie.sineInOut(@currentTime) * (@data.scale.length - 1))
