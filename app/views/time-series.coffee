easie = require("lib/easie")

interpolate = (x, y, p) -> if x >= 0 and y >= 0 then x + (y - x) * p
toThousands = (n) -> Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

arc = (start, finish, r, cx, cy) ->
    t0 = -Math.PI / 2

    t1 = Math.PI * 2 * start
    t2 = Math.PI * 2 * finish

    x1 = (cx + Math.cos(t0 + t1) * r).toFixed(2)
    y1 = (cy + Math.sin(t0 + t1) * r).toFixed(2)
    x2 = (cx + Math.cos(t0 + t2) * r).toFixed(2)
    y2 = (cy + Math.sin(t0 + t2) * r).toFixed(2)

    laf = if finish - start > 0.5 then 1 else 0

    "M #{x1} #{y1} A #{r} #{r} 0 #{laf} 1 #{x2} #{y2}"

module.exports =
  class Chart extends Backbone.View
    data: window.chart
    currentTime: 0

    events:
      "click #btn-play": "play"
      "click #btn-pause": "pause"
      "click #btn-reset": "reset"
      "click #btn-end": "end"
      "click .year-link": "goToYear"
      "click .chart-title-label": "selectKey"
      "chartplay": "pause"
      "chartpause": "pause"
      "chartreset": "reset"

    initialize: (opts) ->
      if opts.items
        @data.items = @data[opts.items]

      @$elements =
        blocks:    {}
        labels:    {}
        item:      @$(".item")
        year:      @$(".year")
        years:     @$("#axis-years-list")
        scale:     @$("#scale-strokes")
        strokes:   @$(".scale-stroke")
        keys:      @$(".chart-title-label")
        breakdown: @$(@data.breakdown)
        total:     @$("#breakdown-total")

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
              parent: item.parent
              index
              isEstimate: @data.scale[x] >= item.after
              value: interpolate(item[key][x], item[key][y], p)
              stack: @data.keys.reduce( (m, k) =>
                m + interpolate(item[k][x], item[k][y], p)
              , 0)
            })
          .sortBy((c, i, arr) =>
            if c.parent and @data.stack
              -arr[c.parent].stack + 1 + 1 / c.stack
            else if @data.stack
              -c.stack
            else
              if c.value? then -c.value else Infinity
          )
          .value()

      list = lists[@activeIndex]

      if @data.scaleType is "absolute"
        vals = _.flatten @data.keys.map((k) => _.pluck(@data.items, k))
        max = _.max vals

      else if @data.stack
        max = _.max(
          lists[0]
            .map((e, i) ->
              val = e.value
              for list in lists.slice(1)
                val += list[i].value
              return val
            )
          )

      else
        max = _.chain(lists).flatten().pluck("value").max().value()

      length = @$elements.strokes.length

      factor = @data.scaleFactor / (1 / length)
      scale  = factor / max
      yearScale = (@$elements.years.children().length - 1) / (@data.scale.length - 1)

      @$elements.year
        .removeClass("active")
        .eq(Math.round(t * yearScale))
        .addClass("active")

      match = false

      for key in _.keys(@data.classes).reverse()
        t1  = easie.sineInOut(parseFloat(key)) * (@data.scale.length - 1)
        val = @data.classes[key]
        @$el.toggleClass(val, not(match) and t >= t1)
        match = match or t >= t1

      @$elements.years.css   transform: "translate3d(0, #{-t * 100 * yearScale}%, 0)"
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

            if @data.showDiff
              diff = value - @data.items[index][key][0]
              @$elements.labels[key].eq(index).next()
              .html([
                if diff < 0 then "&minus;&thinsp;" else "&plus;&thinsp;"
                @data.prefix
                toThousands(Math.abs(diff))
                @data.suffix
              ].join(""))
              .toggleClass("neg", diff < 0)
              .toggleClass("pos", diff > 0)

      for { value, index, isEstimate }, rank in list
        rank = Math.min(rank, @data.limit)

        @$elements.item.eq(index)
          .toggleClass("estimate", isEstimate)
          .css
            transform: "translate3d(0, #{Math.min(rank, @data.limit) * 100}%, 0)"
            opacity: if rank >= @data.limit then 0 else 1

      if @data.breakdown
        total = _.chain(list).pluck("value").reduce(((m,n)-> m + n), 0).value()
        turn  = 0
        radius = @$elements.breakdown.width() / 2

        @$elements.total.html [
          @data.prefix
          (total / @data.breakdownFactor).toFixed(1)
          @data.breakdownSuffix
        ].join("")

        @$elements.breakdown.children().each (i, el) ->
          p0 = turn + 0.002
          p1 = turn + _.find(list, {name: el.dataset.name}).value / total
          turn = p1

          el.setAttribute("d", arc(p0, p1, radius, radius, radius))

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

        if @data.timingFunction is "step"
          @render(Math.abs(t * max))
        else
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
