require.register "views/chart", (exports, require, module) ->
  { colors, font } = require("data/theme")
  utils = require("lib/utils")

  # When this data was collected
  now = 1583968770162
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
            startDate = utils.toDate(el.start, "January", 1).getTime()
            endDate = utils.toDate(el.end, "December", 30).getTime()
            endDate = now if el.end is "present"

            console.error(el) unless(startDate - endDate <= 0)

            _.extend el, { startDate, endDate }

      onResize: ->
        width = Math.min(900, @$el.width())
        isMobile = width < 400
        buffer = 8
        labelW = 136
        labelW = 80 if isMobile

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
          isMobile: isMobile

        @paper ?= window.Snap(@$(".chart").get(0), @config.w, @config.h)

        @render @data.locations

      createLegend: (data) ->
        x = @config.w - @config.labelW

        for { name, mobileName, list }, i in data
          y = @config.barsY + i * (@config.barsH + @config.buffer) + @config.buffer
          text = @paper.text(x, y + @config.buffer + 7, name)
          text.attr(text: mobileName) if @config.isMobile and mobileName
          text.attr(font.style.labelLeft)

        @current = @paper.text(
          0
          15
        ).attr(font.style.labelLeft)

        n = _.chain(data).pluck("list").flatten().countBy({gender: "f"}).value()
        text = """
          Of #{n.true + n.false} historical postings, only #{n.true} are female
        """

        @current.attr({text}).data({text})
        @current.attr({text: ""}) if @config.w < 700

        lx = @config.w - @config.labelW - @config.buffer - 20
        lx = @config.w - (@config.w - 240) / 2 if @config.isMobile

        fbox = @paper.rect(lx, 0, 20, 20)
        ftxt = @paper.text(lx - 8, 15, "Female Postings")
        mbox = @paper.rect(lx - 160, 0, 20, 20)
        mtxt = @paper.text(lx - 168, 15, "Male Postings")
        ftxt.attr(font.style.labelRight)
        mtxt.attr(font.style.labelRight)

        fbox.attr("fill": colors.contrast, "stroke": "none")
        mbox.attr("fill": colors.dark, "stroke": "none")

        @legend = Snap.set(ftxt, mtxt, mbox, fbox)

      render: (data) ->
        ease = mina.easeinout

        @paper.clear()
        @createLegend(data)

        dmin = _.chain(data).pluck("list").flatten().min("startDate").value().startDate
        dmax = now
        len  = dmax - dmin
        y0   = (new Date(dmin)).getFullYear()
        y1   = (new Date(dmax)).getFullYear()
        nb   = y1 - y0

        x = @config.barsX
        w = @config.w - (@config.labelW + @config.buffer)

        for i in [0..nb]
          my = (data.length + 1) * (@config.barsH + @config.buffer) - @config.buffer

          yn = y0 + i
          dc = (yn % 10 is 0) or yn is 2020 or i is 0

          d = new Date(0)
          d.setFullYear(yn)

          yx = x + ((d - dmin) / len) * w
          y1 = @config.barsY + if dc then 0 else 4
          y2 = @config.barsY + my - 16
          y2 += 4 if dc

          yx = Math.min(yx, w)

          line = @paper.line(yx, y1, yx, y2).attr
            stroke: colors.stroke

          if (yn % (if @config.isMobile then 30 else 10) is 0) and i > 0
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

          minWidth = 3

          for el, i in list
            do (el, i) =>
              x1 = (w * (el.startDate - dmin) / len)
              x1 = Math.max(x1, prevX + 1)
              x2 = w * (el.endDate - dmin) / len
              x2 = Math.max(x2, x1)
              w0 = Math.max(x2 - x1, minWidth)
              prevX = x1 + w0

              if el.endDate is now
                w0 = w + minWidth - (x + x1)

              rect = @paper.rect(x + x1, y, w0, @config.barsH).attr
                fill: if el.gender is "f" then colors.contrast else colors.dark
                stroke: "none"

              homs.push(rect)

              rect.data(el)
              rect.mouseover =>
                d = rect.data()

                text = [
                  d.name
                  if d.resident then "(Resident Minister)"
                  if d.acting then "(Acting)"
                  "(#{format(d.start)} – #{format(d.end)})"
                ].join(" ")

                if @config.isMobile
                  @legend.animate({opacity: 0}, @config.duration, mina.easeinout)

                @current.attr({text})

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
                @current.attr(text: if @config.w < 700 then "" else @current.data("text"))
                for hom in homs
                  hom.stop().animate({
                    opacity: 1
                  }, @config.duration, mina.easeinout)

                if @config.isMobile
                  @legend.animate({opacity: 1}, @config.duration, mina.easeinout)

        _.last(homs.items).after(@current)
