{ colors, font } = require("data/theme")

utils =
  toPercent: (n, d = 0) -> "#{(n * 100).toFixed(d)}%"
  toThousands: (n, d = 0) -> n.toFixed(d).replace(/\B(?=(\d{3})+(?!\d))/g, ",")

module.exports =
  class Chart extends Backbone.View
    data: window.chart
    events:
      "input select": "onSelection"

    onSelection: (e) ->
      @render _.find(@data.agencies, name: e.target.value)

    initialize: ->
      @listenTo this, "resize", @onResize
      @onResize()

    onResize: ->
      width = Math.min(900, @$el.width())
      buffer = 8
      labelW = 48

      @config =
        w: width
        h: 360
        duration: 400
        labelW: labelW
        buffer: buffer
        barsH: 20
        barsW: (width - labelW) / 3
        barsX: labelW
        barsY: 56

      if @paper
        # Snap.setViewBox(0, 0, @config.w, @config.h, true)
      else
        window.p = @paper = window.Snap(@$(".chart").get(0), @config.w, @config.h)
        # Snap.setViewBox(0, 0, @config.w, @config.h, true)
        # Snap.setSize('100%', '100%')
        # @paper.customAttributes.active = (t) -> t
        # @paper.customAttributes.raw = (n) ->
        #   @data("format") and { text: @data("format")(n) }

      @render _.find(@data.agencies, name: @$("select").val())

    createLegend: (data) ->
      for year, i in @data.axis
        y = @config.barsY + i * @config.barsH + @config.buffer * i
        @paper.text(0, y + (@config.barsH / 2 + 5), year).attr(font.style.labelLeft)

      @levels = Snap.set()
      for key, i in _.keys(data)
        nb = @data.axis.length
        x = @config.barsX + (@config.barsW + @config.buffer) * i + @config.barsW / 2
        y = @config.barsY + nb * @config.barsH + @config.buffer * nb
        line = @paper.line(x, @config.barsY - @config.buffer, x, y)
        line.attr(stroke: "#e1e5e8")
        text = @paper.text(x, y + @config.buffer + 10, key)
        text.attr(font.style.labelMiddle)
        @levels.push Snap.set(line, text)

      fbox = @paper.rect(320, 6, 20, 20)
      ftxt = @paper.text(348, 21, "Female").data("label": "Female")
      mbox = @paper.rect(416, 6, 20, 20)
      mtxt = @paper.text(444, 21, "Male").data("label": "Male")
      xbox = @paper.rect(504, 6, 20, 20)
      xtxt = @paper.text(532, 21, "No Data").data("label": "No Data")

      ftxt.attr(font.style.labelLeft)
      mtxt.attr(font.style.labelLeft)
      xtxt.attr(font.style.labelLeft)

      fn = (lbl) -> (x) ->
        if x >= 0
          x.toFixed?(0).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        else
          lbl

      ftxt.data(format: fn("Female"))
      mtxt.data(format: fn("Male"))
      xtxt.data(format: (x) ->
        if x >= 0
          "#{(x * 100).toFixed(0)}%"
        else
          "No Data"
      )

      fbox.attr("fill": colors.highlight, "stroke": "none")
      mbox.attr("fill": colors.dark, "stroke": "none")
      xbox.attr("fill": colors.muted, "stroke": "none")

      @legend = Snap.set(ftxt, mtxt, xtxt)


    render: ({name, data}) ->
      ease = mina.easeinout

      if not @bars
        @createLegend(data)

      @bars ?= {}

      for key, j in _.keys(data)
        list = data[key]
        x = @config.barsX + j * (@config.barsW + @config.buffer)
        cx = x + @config.barsW / 2

        @bars[key] ?= []
        @levels.items[j].animate({x: cx, x1: cx, x2: cx}, @config.duration, ease)

        for [f, m], i in list
          y = @config.barsY + i * @config.barsH + @config.buffer * i
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

          if @bars[key][i]
            {bg, set} = @bars[key][i]
            [fr, mr] = set.children()

            bg.stop().animate({x, width: @config.barsW}, @config.duration, ease)

            if ff + mf > 0
              fr.stop().animate({opacity: 1, width: ff * @config.barsW, x}, @config.duration, ease)
              mr.stop().animate({opacity: 1, width: mf * @config.barsW, x: x + ff * @config.barsW}, @config.duration, ease)
            else
              fr.stop().animate({opacity: 0}, @config.duration, ease)
              mr.stop().animate({opacity: 0}, @config.duration, ease)

          else
            bg = @paper.rect(x, y, @config.barsW, @config.barsH)
            fr = @paper.rect(x, y, ff * @config.barsW, @config.barsH)
            mr = @paper.rect(x + ff * @config.barsW, y, mf * @config.barsW, @config.barsH)
            set = @paper.group(fr, mr)
            @bars[key].push({ set, bg })
            bg.attr("fill": colors.muted, "stroke": "none")
            fr.attr("fill": colors.highlight, "stroke": "none")
            mr.attr("fill": colors.dark, "stroke": "none")

            @bindMouseEvents(set)

          fr.data(value: f)
          mr.data(value: m)
          set.data({value: ff, empty})

    bindMouseEvents: (set) ->
      ease = mina.easeinout

      set.mouseover =>
        f = set[0].data("value")
        m = set[1].data("value")

        return if set.data("empty")

        window.clearTimeout @timeout

        [fl, ml, bl] = @legend.items

        if f? and m?
          fl.attr({text: utils.toThousands(f)})
          ml.attr({text: utils.toThousands(m)})

        if f is 0 and m is 0
          bl.attr(text: "No Staff")
        else
          bl.attr(text: utils.toPercent(set.data("value")))

        for key, bars of @bars
          for bar in bars when bar.set isnt set
            bar.set
              .stop()
              .animate({opacity: 0.5}, @config.duration, ease)

      set.mouseout =>
        for key, bars of @bars
          for bar in bars
            bar.set.stop().animate({opacity: 1}, @config.duration, ease)

        window.clearTimeout @timeout
        @timeout = window.setTimeout =>
          for el, i in set.children()
            @legend.items[i].attr({text: @legend.items[i].data("label")})

          @legend.items[2].attr(text: @legend.items[2].data("label"))
        , 300
