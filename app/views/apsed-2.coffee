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

      for agency in @data.agencies
        agency.totals = {}

        for band, list of agency.bands
          console.error(agency) if list.m.length isnt 23
          console.error(agency) if list.f.length isnt 23

        for g in ["f", "m"]
          agency.totals[junior] ?= {}
          agency.totals[junior][g] =
            for i in [0...@data.yAxis.length]
              agency.bands["Trainee & Graduate"][g][i] +
              agency.bands["APS 1"][g][i] +
              agency.bands["APS 2"][g][i] +
              agency.bands["APS 3"][g][i] +
              agency.bands["APS 4"][g][i] +
              agency.bands["APS 5"][g][i] +
              agency.bands["APS 6"][g][i] +
              agency.bands["EL 1"][g][i] +
              agency.bands["EL 2"][g][i]

          agency.totals[senior] ?= {}
          agency.totals[senior][g] =
            for i in [0...@data.yAxis.length]
              agency.bands["SES 1"][g][i] +
              agency.bands["SES 2"][g][i] +
              agency.bands["SES 3"][g][i]

          agency.totals[total] ?= {}
          agency.totals[total][g] =
            for i in [0...@data.yAxis.length]
              agency.bands["Total"][g][i]

        for key, list of agency.totals
          for g in ["f", "m"]
            for v, i in list[g]
              list[g][i] = undefined unless v >= 0

    onResize: ->
      width = Math.min(900, @$el.width())
      buffer = 8
      labelW = 36

      @config =
        w: width
        h: @$el.height()
        duration: 400
        labelW: labelW
        buffer: buffer
        barsH: 20
        barsW: (width - labelW) / 3 - buffer
        barsX: labelW + buffer
        barsY: 48

      @paper ?= window.Snap(@$(".chart").get(0), @config.w, @config.h)

      @render @data.agencies[+@$("select").val()]

    createLegend: ->
      for year, i in @data.yAxis
        y = @config.barsY + i * (@config.barsH + @config.buffer)
        @paper.text(@config.labelW, y + (@config.barsH / 2 + 5), year).attr(font.style.labelRight)

      @levels = Snap.set()
      for key, i in @data.xAxis
        nb = @data.yAxis.length
        x = @config.barsX + (@config.barsW + @config.buffer) * i + @config.barsW / 2
        y = @config.barsY + nb * (@config.barsH + @config.buffer)
        line = @paper.line(x, @config.barsY - @config.buffer, x, y)
        line.attr(stroke: "#e1e5e8")
        text = @paper.text(x, y + @config.buffer + 9, key)
        text.attr(font.style.labelMiddle)
        @levels.push Snap.set(line, text)

      mbox = @paper.rect(@config.w - 20, 6, 20, 20)
      mtxt = @paper.text(@config.w - 28, 21, "Male Staff").data("label": "Male Staff")
      fbox = @paper.rect(@config.w - 180, 6, 20, 20)
      ftxt = @paper.text(@config.w - 188, 21, "Female Staff").data("label": "Female Staff")

      ftxt.attr(font.style.labelRight)
      mtxt.attr(font.style.labelRight)

      fbox.attr("fill": colors.contrast, "stroke": "none")
      mbox.attr("fill": colors.dark, "stroke": "none")

      @legend = Snap.set(ftxt, mtxt)

    render: ({name, bands, totals}) ->
      ease = mina.easeinout
      isFirstRun = not @bars

      @createLegend() if isFirstRun

      @bars ?= {}

      for key, j in @data.xAxis
        list = _.zip(totals[key].f, totals[key].m)
        console.log(list)

        x = @config.barsX + j * (@config.barsW + @config.buffer)
        cx = x + @config.barsW / 2

        @bars[key] ?= []
        @levels.items[j].animate({x: cx, x1: cx, x2: cx}, @config.duration, ease)

        for [f, m], i in list
          y = @config.barsY + i * (@config.barsH + @config.buffer)
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
            bg = @paper.rect(x, y, @config.barsW, @config.barsH)
            fr = @paper.rect(x, y, ff * @config.barsW, @config.barsH)
            mr = @paper.rect(x + ff * @config.barsW, y, mf * @config.barsW, @config.barsH)
            set = @paper.group(fr, mr)
            @bars[key].push({ set, bg })
            bg.attr(fill: colors.muted, stroke: "none")
            fr.attr(fill: colors.contrast, stroke: "none")
            mr.attr(fill: colors.dark, stroke: "none")

            @bindMouseEvents(set)

          else
            {bg, set} = @bars[key][i]
            [fr, mr] = set.children()

            if ff + mf > 0
              fr.stop().animate({opacity: 1, width: ff * @config.barsW, x}, @config.duration, ease)
              mr.stop().animate({opacity: 1, width: mf * @config.barsW, x: x + ff * @config.barsW}, @config.duration, ease)
            else
              fr.stop().animate({opacity: 0}, @config.duration, ease)
              mr.stop().animate({opacity: 0}, @config.duration, ease)

            if not f?
              bg.stop().animate({x, width: @config.barsW, fill: colors.muted}, @config.duration, ease)
            else
              bg.stop().animate({x, width: @config.barsW, fill: "#b6c1c6"}, @config.duration, ease)


          fr.data(value: f)
          mr.data(value: m)
          set.data({ff, mf, empty})

        # if isFirstRun
        #   y = 224
        #   v = @data.totals[key]
        #   set = @paper.group(
        #     @paper
        #       .rect(x, y, v * @config.barsW, @config.barsH)
        #       .attr(fill: colors.contrast, stroke: "none")
        #   ,
        #     @paper
        #       .rect(x + v * @config.barsW, y, (1 - v) * @config.barsW, @config.barsH)
        #       .attr(fill: colors.dark, stroke: "none")
        #   ).data({ff: v, mf: 1 - v})

        #   @bindMouseEvents(set)
        #   @bars[key].push({ set })


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
            bar.set.stop().animate({opacity: 0.5}, @config.duration, ease)

      set.mouseout =>
        for key, bars of @bars
          for bar in bars
            bar.set.stop().animate({opacity: 1}, @config.duration, ease)

        window.clearTimeout @timeout
        @timeout = window.setTimeout =>
          for el, i in set.children()
            @legend.items[i].attr({text: @legend.items[i].data("label")})

        , 300