require.register "views/map", (exports, require, module) ->
  class MapView extends Backbone.View
    easie = require("lib/easie")

    interpolate = (x, y, p) -> if x >= 0 and y >= 0 then x + (y - x) * p
    toThousands = (n) -> Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

    module.exports =
      class MapView extends Backbone.View
        data: window.chart

        events:
          "click #btn-play": "play"
          "click #btn-pause": "pause"
          "click #btn-reset": "reset"
          "click #btn-end": "end"

          "pointerdown #map-timeline-minimap": "startYear"
          "pointercancel": "endYear"

        interpolate: d3.interpolateRgbBasis(["#0056fa","#fff","#fa0051"])

        createScale: ->
          values = _.chain(@data.items).map("values").flatten().filter().value()
          min = _.min(values)
          max = _.max(values)

          range = (i / 5 for i in [0..5])

          cn = d3.scaleQuantile(values.filter((n) -> n > 1), range)
          us = d3.scaleQuantile(values.filter((n) -> n < 1), range)

          @scale = (n) -> if n > 1 then 0.5 + cn(n) / 2 else us(n) / 2

        initialize: (opts) ->
          @createScale()

          $(window).on("pointerup", _.bind(@endYear, this))
          $(window).on("pointermove", _.bind(@moveYear, this))

          if opts.items
            @data.items = @data[opts.items]

          d3.json("./output.json").then (topo) =>

            @$elements =
              blocks:  {}
              labels:  {}
              map:     @$("#map")
              scale:   @$("#map-scale-canvas")
              year:    @$("#chart-year")
              minimap: @$("#map-timeline-minimap")
              keys:    @$(".chart-title-label")

            @$el.addClass("loading")
            @drawMap(topo)
            @drawScale()
            @drawMinimap()
            @reset()

            window.setTimeout (=>
              @play()
              @$el.removeClass("loading")
            ), 600

            @listenTo this, "resize", =>
              @drawMap(topo)
              @render(@currentTime * (@data.scale.length - 1)) unless @playing

        drawMap: (topo) ->
          countries = topojson.feature(topo, topo.objects.countries)
          ocountries = topojson.feature(topo, topo.objects.cshapes)

          background = topojson.merge(topo, topo.objects.countries.geometries)

          countries.features =
            _.uniq(
              countries.features
                .concat(ocountries.features)
                .filter((c) => _.find(@data.items, code: c.properties.ADM0_A3))
              (c) -> c.properties.ADM0_A3
            )

          svg = d3.select("svg")

          svg
            .selectAll("*")
            .remove()

          width  = @$elements.map.width()
          height = @$elements.map.height()

          projection = d3.geoPatterson()
            .rotate([-10, 0, 0])
            .precision(.1)
            .fitExtent([[0, -80],[width, height + 160]], background)

          path = d3.geoPath().projection(projection)

          bounds = path.bounds(background)

          if bounds[1][1] < height
            svg
              .append("rect")
              .attr("class", "country")
              .attr("y", bounds[1][1])
              .attr("width", width)
              .attr("height", height - bounds[1][1])


          svg
            .append("path")
            .datum(background)
            .attr("d", path)
            .attr("class", "background")

          @$elements.countries = svg
            .append("g")
            .attr("class", "countries")
            .selectAll(".country")
            .data(countries.features, (d) -> d.properties.ADM0_A3)
            .enter()
            .insert("path")
            .attr("class", "country")
            .attr("title", (d) -> d.properties.ADMIN)
            .attr("id", (d) -> "country-" + d.properties.ADM0_A3 )
            .attr("d", path)

        drawScale: ->
          canvas = @$elements.scale.get(0)
          canvas.width = canvas.width * 2
          canvas.height = 2
          context = canvas.getContext("2d")

          for i in [0...canvas.width]
            context.fillStyle = @interpolate(i / (canvas.width - 2))
            context.fillRect(i, 0, 2, 2)

          return

          values = _.chain(@data.items)
            .pluck("values")
            .flatten()
            .compact()
            .value()
            .sort((a, b) -> a - b)

          last = null
          w = canvas.width / values.length

          for v, i in values
            x = i * w
            context.fillStyle = @interpolate(@scale(v))
            context.fillRect(x, 1, w + 2, 2)

        drawMinimap: ->
          canvas = @$elements.minimap.get(0)

          canvas.width  = @$elements.minimap.width() * 2
          canvas.height = @data.items.length

          @$elements.minimapContext = canvas.getContext("2d")

          resolution  = 2
          canvasColor = document.createElement("canvas")
          canvasColor.width  = @data.scale.length * resolution
          canvasColor.height = @data.items.length
          contextColor = canvasColor.getContext("2d")

          for year, i in @data.scale
            for country, y in @data.items
              v1 = country.values[i]
              v2 = country.values[Math.min(i + 1, @data.scale.length - 1)]

              a1 = if v1 then 1 else 0
              a2 = if v2 then 1 else 0

              for j in [0..resolution]
                v1 = v2 or 1 unless v1
                v2 = v1 or 1 unless v2
                x = i * resolution + j
                t = j / resolution
                a = interpolate(a1, a2, t)
                v = interpolate(v1, v2, t)

                contextColor.globalAlpha = a
                contextColor.fillStyle = @interpolate(@scale(v))
                contextColor.fillRect(x, y, 1, 1)

          @data.colorImage = canvasColor

          canvasBase = document.createElement("canvas")
          canvasBase.width  = canvas.width
          canvasBase.height = canvas.height
          contextBase = canvasBase.getContext("2d")

          contextBase.drawImage(@data.colorImage, 0, 0, canvas.width, canvas.height)
          contextBase.globalCompositeOperation = "source-in"
          contextBase.fillStyle = "#cfd9e2"
          contextBase.fillRect(0, 0, canvas.width, canvas.height)

          @data.baseImage = canvasBase

        drawMinimapAt: (t) ->
          w = @data.baseImage.width
          h = @data.baseImage.height
          x = t / (@data.scale.length - 1) * (w - 2)

          @$elements.minimapContext.clearRect(0, 0, w, h)
          @$elements.minimapContext.save()
          @$elements.minimapContext.drawImage(@data.baseImage, 0, 0)
          @$elements.minimapContext.beginPath()
          @$elements.minimapContext.rect(0, 0, x, @data.baseImage.height)
          @$elements.minimapContext.clip()

          @$elements.minimapContext.drawImage(@data.colorImage, 0, 0, @data.baseImage.width, @data.baseImage.height)
          @$elements.minimapContext.restore()

          @$elements.minimapContext.strokeStyle = "#002a45"
          @$elements.minimapContext.lineWidth = 2
          @$elements.minimapContext.strokeRect(1, 1, @data.baseImage.width - 2, @data.baseImage.height - 2)
          @$elements.minimapContext.strokeRect(x + 1, 0, 1, @data.baseImage.height)

        render: (t) ->
          x = Math.floor(t)
          y = Math.min(x + 1, @data.scale.length - 1)
          p = t - x

          @$elements.year.html @data.scale[0] + Math.round(t)

          data = @$elements.countries.data()

          for country in data
            item  = _.find @data.items, code: country.properties.ADM0_A3
            if item
              vx = item.values[x]
              vy = item.values[y]
              sx = @scale(vx or 1)
              sy = @scale(vy or 1)
              value = interpolate(sx, sy, p)
              country.properties.opacity = if not(vx and vy) then 0 else 1
              country.properties.fill = @interpolate(value)

          @$elements.countries
            .data(data, (d) -> d.properties.ADM0_A3)
            .style("fill", (d) -> d.properties.fill)
            .style("opacity", (d) -> d.properties.opacity)

          @drawMinimapAt(t)

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

            @render(t * max)

            if t < 1 and @playing
              @currentTime = t
              @loop = window.requestAnimationFrame(repeat)
            else if @playing
              @$el.removeClass("playing")
              @currentTime = 1
              @playing = false

        pause: ->
          if @playing
            @stop()
          else
            @play()

        stop: ->
          window.cancelAnimationFrame(@loop)
          @playing = false
          @$el.removeClass("playing")

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

        startYear: (e) ->
          @stop()
          @trackPosition = true
          @moveYear(e)

        moveYear: (e) ->
          return unless @trackPosition

          o = @$elements.minimap.offset()
          x = e.clientX
          t = (x - o.left) / @$elements.minimap.width()

          t = Math.min Math.max(t, 0), 1

          @currentTime = t

          @render(t * (@data.scale.length - 1))

        endYear: (e) ->
          @trackPosition = false
