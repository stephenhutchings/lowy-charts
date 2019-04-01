require.register "views/scroller", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")

  class ScrollerView extends Backbone.View
    events:
      "show": "onShow"
      "hide": "onHide"

    initialize: ->
      @data = @$el.data()

      @data.support = window.CSS?.supports("scroll-snap-type: y mandatory")

      @$elements =
        pager: $(@$el.data("pager"))
        index: $(@$el.data("index"))

      timeout = null

      $("#btn-prev").click (e) => @onPrev(e)
      $("#btn-next").click (e) => @onNext(e)

      @$el.on("scroll", (e) =>
        @onScroll()
        window.clearTimeout timeout
        timeout = window.setTimeout =>
          @onScrollEnd()
        , if @data.support then 10 else 300
      )

      timeout = window.setTimeout =>
        @onScrollEnd()
      , 1

      if @$el.outerWidth() <= 600
        $("br").each (i, el) ->
          $(el).replaceWith(" ")

    onScroll: ->
      i  = Math.floor @el.scrollTop / @el.offsetHeight
      i2 = Math.floor @el.scrollTop / @el.offsetHeight + 0.5
      t1 = (@el.scrollTop / @el.offsetHeight) % 1
      t2 = Math.sin(Math.PI * t1)

      i  -= @data.min

      i2 = Math.max(Math.min(i2, @data.max), @data.min)

      if t1 < 0.5 and i < 0
        t2 = 1

      w = t2
      x = if t1 > 0.5 then (1-t2) else 0
      k = 0

      if i < 0
        k = 2
        x -= k
        w += k

      @$elements.index.html(i2)
      @$elements.pager.css "transform": "translateX(#{i * 200}%)"

      @$elements.pager.children().eq(0).css
        "transform": "translate3d(#{x * 400 + k * (1-t2) * 400}%, 0, 0)"

      @$elements.pager.children().eq(1).css
        "transform": "translate3d(#{-4 + x * 100 + k * (1-t2) * 100}%, 0, 0) scale(#{t2 * (k + 1) + 0.1}, 1)"

      @$elements.pager.children().eq(2).css
        "transform": "translate3d(#{(x + w) * 400}%, 0, 0)"

    onScrollEnd: ->
      index = Math.floor @el.scrollTop / @el.offsetHeight + 0.5

      unless @data.support
        @scrollTo(index)

      if index isnt @data.i
        $("body")
          .removeClass("page-#{@data.i}")
          .addClass("page-#{index}")

        _.extend @data,
          y: @el.scrollTop
          h: @el.offsetHeight
          i: index

        for child, i in @el.children
          child.classList.toggle("active", i is @data.i)
          $("[data-view]", child).trigger(
            if i is @data.i then "show" else "hide"
          )

        window.ga?("send", "event", "Scroller", "show", document.title, index)

    onPrev: ->
      index = Math.floor @el.scrollTop / @el.offsetHeight + 0.5
      @scrollTo(index - 1)

    onNext: ->
      index = Math.floor @el.scrollTop / @el.offsetHeight + 0.5
      @scrollTo(index + 1)

    scrollTo: (i) ->
      @$el.addClass("scrolling")
      @$el.scrollTo i * @el.offsetHeight, =>
        @$el.removeClass("scrolling")

  module.exports = ScrollerView
