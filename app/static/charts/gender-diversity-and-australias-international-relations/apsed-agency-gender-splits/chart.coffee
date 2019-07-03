require.register "views/chart", (exports, require, module) ->
  { colors, font } = require("data/theme")

  utils =
    toPercent: (n, d = 0) -> "#{(n * 100).toFixed(d)}%"
    toThousands: (n, d = 0) -> n.toFixed(d).replace(/\B(?=(\d{3})+(?!\d))/g, ",")

  module.exports =
    class Chart extends Backbone.View
      data: window.chart
      events:
        "input select": "onSelection"
        "click .btn-l": "onPrev"
        "click .btn-r": "onNext"

      onPrev: (e) ->
        $opts = @$("select option")
        index = @$(":selected", $opts).index() - 1
        index = $opts.length - 1 if index < 0

        $opts.parent().val($opts.eq(index).val()).trigger("input")

      onNext: (e) ->
        $opts = @$("select option")
        index = @$(":selected", $opts).index() + 1
        index = 0 if index > $opts.length - 1

        $opts.parent().val($opts.eq(index).val()).trigger("input")

      onSelection: (e) ->
        @render @data.agencies[+e.target.value]

      initialize: ->
        @normalizeData()
        @listenTo this, "resize", @onResize
        @onResize()

      normalizeData: ->
        [total, junior, senior] = @data.xAxis

        combine = (keys, g, i) ->
          _.chain(agency.bands)
            .pick(keys)
            .values()
            .reduce(((m, e) -> m + (e[g][i] or 0)), 0)
            .value()

        for agency in @data.agencies
          agency.totals ?= {}

          # Check for bands with missing data
          if agency.bands
            for band, list of agency.bands
              console.error(agency) if list.m.length isnt agency.years.length
              console.error(agency) if list.f.length isnt agency.years.length

              for g in ["f", "m"]
                agency.bands[band][g] = (
                  for year in @data.yAxis
                    i = agency.years.indexOf(year)
                    if i >= 0 then list[g][i]
                )

            # Combine different bands into three grades
            for g in ["f", "m"]
              agency.totals[junior] ?= {}
              agency.totals[junior][g] =
                combine(@data.defs.junior, g, i) for y, i in @data.yAxis

              agency.totals[senior] ?= {}
              agency.totals[senior][g] =
                combine(@data.defs.senior, g, i) for y, i in @data.yAxis

              agency.totals[total] ?= {}
              agency.totals[total][g] =
                combine(["Total"], g, i) for y, i in @data.yAxis

          else
            # Some agencies just include total band data
            if not agency.totals
              console.error "#{agency.name} has no data"

            for g in ["f", "m"]
              for key, val of agency.totals
                agency.totals[key][g] =
                  for year in @data.yAxis
                    i = agency.years.indexOf(year)
                    if i >= 0 then val[g][i] else 0

          # Unset non-numeric data
          for key, list of agency.totals
            for g in ["f", "m"]
              for v, i in list[g]
                list[g][i] = undefined unless v >= 0

      onResize: ->
        width = Math.min(900, @$el.width())
        vBuffer = 4
        hBuffer = 12
        labelW = 57

        @config =
          w: width
          h: @$el.height()
          duration: 400
          labelW: labelW
          vBuffer: vBuffer
          hBuffer: hBuffer
          barsH: 16
          barsW: (width - labelW) / 3 - hBuffer
          barsX: labelW + hBuffer
          barsY: 48

        @paper ?= window.Snap(@$(".chart").get(0), @config.w, @config.h)

        @render @data.agencies[+@$("select").val()]

      createLegend: ->
        for year, i in @data.yAxis
          y = @config.barsY + i * (@config.barsH + @config.vBuffer)
          t = @paper.text(@config.labelW, y + (@config.barsH / 2 + 5), year).attr(font.style.labelRight)
          t.attr(opacity: 0.3) if year % 5 isnt 0

        @levels = Snap.set()

        @paper.line(0, 512, @config.w, 512).attr(stroke: "#e1e5e8")
        @paper.text(@config.labelW + 4, y + 45, "APS Avg.").attr(font.style.labelRight)

        for key, i in @data.xAxis
          nb = @data.yAxis.length
          x = @config.barsX + (@config.barsW + @config.hBuffer) * i + @config.barsW / 2
          y = @config.barsY + nb * (@config.barsH + @config.vBuffer) + 32
          text = @paper.text(x, y + @config.vBuffer + 15, key)
          text.attr(font.style.labelMiddle)
          @levels.push Snap.set(text)

        mbox = @paper.rect(@config.w - 20, 6, 20, 20)
        mtxt = @paper.text(@config.w - 28, 21, "Male Staff").data("label": "Male Staff")
        fbox = @paper.rect(@config.w - 180, 6, 20, 20)
        ftxt = @paper.text(@config.w - 188, 21, "Female Staff").data("label": "Female Staff")

        ftxt.attr(font.style.labelRight)
        mtxt.attr(font.style.labelRight)

        fbox.attr("fill": colors.contrast, "stroke": "none")
        mbox.attr("fill": colors.dark, "stroke": "none")

        @legend = Snap.set(ftxt, mtxt)

      render: ({name, years, bands, totals}) ->
        ease = mina.easeinout
        isFirstRun = not @bars

        @createLegend() if isFirstRun

        @bars ?= {}

        for key, j in @data.xAxis
          list = _.zip(totals[key].f, totals[key].m)

          x = @config.barsX + j * (@config.barsW + @config.hBuffer)
          cx = x + @config.barsW / 2

          @bars[key] ?= []
          @levels.items[j].animate({x: cx, x1: cx, x2: cx}, @config.duration, ease)

          for [f, m], i in list
            y = @config.barsY + i * (@config.barsH + @config.vBuffer)
            empty = false

            if not f?
              empty = true
              ff = mf = 0

            else if not m?
              ff = f / 100
              mf = 1 - ff

            else
              ff = if f is 0 then 0 else f / (m + f)
              mf = if m is 0 then 0 else m / (m + f)

            if isFirstRun
              bg = @paper.rect(x, y + @config.barsH / 2 - 1.5, @config.barsW, 3)
              fr = @paper.rect(x + mf * @config.barsW / 2, y, ff * @config.barsW / 2, @config.barsH)
              mr = @paper.rect(x + @config.barsW / 2, y, mf * @config.barsW / 2, @config.barsH)
              set = @paper.group(fr, mr)
              @bars[key].push({ set, bg })
              bg.attr(fill: colors.muted, stroke: "none")
              fr.attr(fill: colors.contrast, stroke: "none").data(color: "contrast")
              mr.attr(fill: colors.dark, stroke: "none").data(color: "dark")

              @bindMouseEvents(set)

            else
              {bg, set} = @bars[key][i]
              [fr, mr] = set.children()

              bg.stop().animate({width: @config.barsW, x}, @config.duration, ease)

              if ff + mf > 0
                fr.removeClass("no-touch")
                mr.removeClass("no-touch")
                fr.stop().animate({opacity: 1, width: ff * @config.barsW / 2, x: x + mf * @config.barsW / 2}, @config.duration, ease)
                mr.stop().animate({opacity: 1, width: mf * @config.barsW / 2, x: x + @config.barsW / 2}, @config.duration, ease)
              else
                fr.addClass("no-touch")
                mr.addClass("no-touch")
                fr.stop().animate({opacity: 0}, @config.duration, ease)
                mr.stop().animate({opacity: 0}, @config.duration, ease)

              if not f?
                bg.stop().animate({x, width: @config.barsW, fill: colors.muted}, @config.duration, ease)

            fr.data(value: f)
            mr.data(value: m)
            set.data({ff, mf, empty})

          if isFirstRun
            y = 520
            v = @data.totals[key]
            bg = @paper.rect(x, y + @config.barsH / 2 - 1.5, @config.barsW, 3)
            bg.attr(fill: colors.muted, stroke: "none")

            set = @paper.group(
              @paper
                .rect(x + ((1 - v) * @config.barsW / 2), y, v * @config.barsW / 2, @config.barsH)
                .attr(fill: colors.contrast, stroke: "none")
                .data(color: "contrast")
            ,
              @paper
                .rect(x + @config.barsW / 2, y, (1 - v) * @config.barsW / 2, @config.barsH)
                .attr(fill: colors.dark, stroke: "none")
                .data(color: "dark")
            ).data({ff: v, mf: 1 - v})

            @bars[key].push({ set, bg })
            @bindMouseEvents(set)

          else
            { set, bg } = _.last(@bars[key])
            bg.stop().animate({width: @config.barsW, x}, @config.duration, ease)
            [r1, r2] = set.children()
            v = set.data("ff")
            r1.stop().animate({x: x + ((1 - v) * @config.barsW / 2), width: v * @config.barsW / 2}, @config.duration, ease)
            r2.stop().animate({x: x + @config.barsW / 2, width: (1 - v) * @config.barsW / 2}, @config.duration, ease)


      bindMouseEvents: (set) ->
        ease = mina.easeinout

        set.mouseover =>
          f = set[0].data("value")
          m = set[1].data("value")

          return if set.data("empty")

          window.clearTimeout @timeout

          [fl, ml, bl] = @legend.items

          if f? and m?
            fl.attr text: """
              #{utils.toThousands(f)} #{if f is 1 then "Woman" else "Women"}
              (#{utils.toPercent(set.data("ff"))})
            """
            ml.attr text: """
              #{utils.toThousands(m)} #{if m is 1 then "Man" else "Men"}
              (#{utils.toPercent(set.data("mf"))})
            """
          else if set.data("ff")?
            fl.attr text: """
              Women (#{utils.toPercent(set.data("ff"))})
            """
            ml.attr text: """
              Men (#{utils.toPercent(1 - set.data("ff"))})
            """

          for key, bars of @bars
            for bar in bars when bar.set isnt set
              for g in bar.set.children()
                g.stop().animate({fill: colors.pale[g.data("color")]}, @config.duration, ease)

        set.mouseout =>
          for key, bars of @bars
            for bar in bars
              for g in bar.set.children()
                g.stop().animate({fill: colors[g.data("color")]}, @config.duration, ease)

          window.clearTimeout @timeout
          @timeout = window.setTimeout =>
            for el, i in set.children()
              @legend.items[i].attr({text: @legend.items[i].data("label")})

          , 300
