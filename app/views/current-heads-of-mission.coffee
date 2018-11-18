{ colors, font } = require("data/theme")
utils = require("lib/utils")

module.exports =
  class Chart extends Backbone.View
    data: window.chart

    initialize: ->
      @normalizeData()
      @listenTo this, "resize", @onResize
      @onResize()

    normalizeData: ->
      m = _.where(@data.posts, {gender: "M"})
      f = _.where(@data.posts, {gender: "F"})

      m = _.sortBy(m, "country")
      f = _.sortBy(f, "country")

      @data.posts = f.concat(m)
      @data.split = { m, f }

    onResize: ->
      barSize = 20
      width = Math.min(340, @$el.width())
      width = width - width % barSize
      buffer = 8
      labelW = 128

      @config =
        w: width
        h: @$el.height()
        duration: 300
        labelW: labelW
        buffer: buffer
        barsH: barSize
        barsX: 0
        barsY: 28

      @paper ?= window.Snap(@$(".chart").get(0), @config.w, @config.h)

      @render @data.posts

    createLegend: (data) ->
      lx = 0
      y  = @config.h - 20
      fbox = @paper.rect(lx, y, 20, 20)
      ftxt = @paper.text(lx + 28, y + 15, "Female Postings")
      mbox = @paper.rect(lx + 160, y, 20, 20)
      mtxt = @paper.text(lx + 188, y + 15, "Male Postings")
      ftxt.attr(font.style.labelLeft)
      mtxt.attr(font.style.labelLeft)

      fbox.attr("fill": colors.highlight, "stroke": "none")
      mbox.attr("fill": colors.dark, "stroke": "none")

      text = """
        Only 1 in 3 Heads of Mission Are Women
      """

      @current = @paper
        .text(0, 16)
        .attr(font.style.labelLeft)
        .attr({text})
        .data({text})

    render: (data) ->
      @createLegend() if not @posts

      @posts ?= Snap.set()

      for post, i in data
        x = @config.barsH * i % @config.w
        y = @config.barsY + Math.floor(i * @config.barsH / @config.w) * @config.barsH

        if @posts.items.length is i
          rect = @paper
            .rect(x, y, @config.barsH, @config.barsH)
            .data(post)
            .attr(
              fill: if post.gender is "M" then colors.dark else colors.highlight
              stroke: "#fff"
            )

          @posts.push(rect)
          @bindMouseEvents(rect)
        else
          @posts.items[i].attr({x, y})


    bindMouseEvents: (el) ->
      data = el.data()
      el.mouseover =>
        @current.attr(text: """
          #{data.type} in #{data.city}, #{data.country}
        """
        )
        # .animate({opacity: 1}, @config.duration, mina.easeinout)

        for rect in @posts when rect isnt el
          rect.animate({opacity: 0.5}, @config.duration, mina.easeinout)

      el.mouseout =>
        # @current.animate({opacity: 0}, @config.duration, mina.easeinout)
        @current.attr(text: @current.data("text"))

        for rect in @posts
          rect.animate({opacity: 1}, @config.duration, mina.easeinout)
