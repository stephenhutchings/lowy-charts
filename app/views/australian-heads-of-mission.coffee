{ colors, font } = require("data/theme")

utils =
  toPercent: (n, d = 0) -> "#{(n * 100).toFixed(d)}%"
  toThousands: (n, d = 0) -> n.toFixed(d).replace(/\B(?=(\d{3})+(?!\d))/g, ",")

# When this data was collected
now = 1542517640615
format = (d) ->
  if _.isString(d) and d.match(/(\d{1,2} |)[a-z]+ \d{4}/i)
    d.toString().replace(/([a-z]+)/i, (w, a) -> a.slice(0, 3))
  else
    d

module.exports =
  class Chart extends Backbone.View
    data: window.chart

    initialize: ->
      @normalizeData()
      @listenTo this, "resize", @onResize
      @onResize()

    normalizeData: ->
      for { list } in @data.locations
        for el in list
          if el.start.toString().match(/^\d{4}$/)
            startDate = new Date("June 30 #{el.start}").getTime()
          else
            startDate = new Date(el.start.toString()).getTime()
          endDate =   new Date(el.end.toString()).getTime()
          endDate =   now if el.end is "present"

          if el.end.toString().match(/^\d{4}$/)
            endDate = new Date("July 1 #{el.end}").getTime()

          console.error(el) unless(startDate - endDate <= 0)

          _.extend el, { startDate, endDate }

    onResize: ->
      width = Math.min(900, @$el.width())
      buffer = 8
      labelW = 128

      @config =
        w: width
        h: @$el.height()
        duration: 400
        labelW: labelW
        buffer: buffer
        barsH: 20
        barsW: (width - labelW) / 3
        barsX: 0
        barsY: 40

      @paper ?= window.Snap(@$(".chart").get(0), @config.w, @config.h)

      @render @data.locations

    createLegend: (data) ->
      x = @config.w - @config.labelW

      for { name, list }, i in data
        y = @config.barsY + i * (@config.barsH + @config.buffer) + @config.buffer
        text = @paper.text(x, y + @config.buffer + 7, name)
        text.attr(font.style.labelLeft)

      @current = @paper.text(
        0
        16
      ).attr(font.style.labelLeft)

      n = _.chain(data).pluck("list").flatten().countBy({gender: "f"}).value()
      text = """
        Of #{n.true + n.false} historical postings, only #{n.true} are female
      """

      @current.attr({text}).data({text})
      @current.attr({text: ""}) if @config.w < 700

      lx = @config.w - @config.labelW - @config.buffer - 20
      fbox = @paper.rect(lx, 0, 20, 20)
      ftxt = @paper.text(lx - 8, 15, "Female Postings")
      mbox = @paper.rect(lx - 160, 0, 20, 20)
      mtxt = @paper.text(lx - 168, 15, "Male Postings")
      ftxt.attr(font.style.labelRight)
      mtxt.attr(font.style.labelRight)

      fbox.attr("fill": colors.highlight, "stroke": "none")
      mbox.attr("fill": colors.dark, "stroke": "none")

      @legend = Snap.set(ftxt, mtxt)

    render: (data) ->
      ease = mina.easeinout

      @paper.clear()
      @createLegend(data)


      dmin = _.chain(data).pluck("list").flatten().min("startDate").value().startDate
      dmax = now
      len  = dmax - dmin

      x = @config.barsX
      w = @config.w - (@config.labelW + @config.buffer)
      year = 1000 * 60 * 60 * 24 * 365

      for i in [0..Math.ceil(len / year)]
        my = (data.length + 1) * (@config.barsH + @config.buffer) - @config.buffer
        fy = new Date(dmin).getFullYear()
        yn = fy + i
        dc = (yn % 10 is 0) or yn is 2019 or i is 0
        yx = x + (-dmin % year) / year + (year / len) * i * (w - 2)
        y1 = @config.barsY + if dc then 0 else 4
        y2 = @config.barsY + my - 16
        y2 += 4 if dc

        yx = Math.min(yx, w)

        line = @paper.line(yx, y1, yx, y2).attr
          stroke: colors.stroke

        if (yn % 10 is 0) and i > 0
          @paper.text(yx, @config.barsY + my + 4, yn).attr(font.style.labelMiddle)

        unless dc
          line.attr(stroke: colors.muted, opacity: 0.5)

      homs = Snap.set()

      for { name, list }, j in data
        y = @config.barsY + j * (@config.barsH + @config.buffer) + @config.buffer
        prevX = -1

        @paper.rect(x, y, w, @config.barsH).attr
          fill: colors.muted
          stroke: "none"
          opacity: 0.5

        for el, i in list
          do (el, i) =>
            x1 = (w * (el.startDate - dmin) / len)
            x1 = Math.max(x1, prevX + 1)
            x2 = w * (el.endDate - dmin) / len
            x2 = Math.max(x2, x1 + 3)
            prevX = x2
            rect = @paper.rect(x + x1, y, x2 - x1, @config.barsH).attr
              fill: if el.gender is "f" then colors.highlight else colors.dark
              stroke: "none"

            homs.push(rect)

            rect.data(el)
            rect.mouseover =>
              d = rect.data()

              text = [
                d.name
                if d.resident then "(Resident Minister)"
                "(#{format(d.start)} – #{format(d.end)})"
              ].join(" ")

              text = d.name if @config.w < 700

              @current
                .attr({text})
                # .animate({opacity: 1}, @config.duration, mina.easeinout)

              for hom in homs
                if hom.data("name") is d.name
                  hom.stop().animate({
                    opacity: 1
                  }, @config.duration, mina.easeinout)
                else
                  hom.stop().animate({
                    opacity: 0.3
                  }, @config.duration, mina.easeinout)

            rect.mouseout =>
              # @current.animate({opacity: 0}, @config.duration, mina.easeinout)
              @current.attr(text: if @config.w < 700 then "" else @current.data("text"))
              for hom in homs
                hom.stop().animate({
                  opacity: 1
                }, @config.duration, mina.easeinout)

      _.last(homs.items).after(@current)
