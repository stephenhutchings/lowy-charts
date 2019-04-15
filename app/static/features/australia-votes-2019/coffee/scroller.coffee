require.register "views/scroller", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")
  keycode  = require("lib/keycode")

  class ScrollerView extends Backbone.View
    events:
      "show": "onShow"
      "hide": "onHide"


    initialize: ->
      @data = _.extend {min: 0, max: 1000}, @$el.data()

      @data.support = window.CSS?.supports("scroll-snap-type: y mandatory")

      @$elements =
        pager: $(@$el.data("pager"))
        index: $(@$el.data("index"))
        items: $(".pager-item")

      @listenTo this, "resize", @onResize

      timeout = null

      @$el.on("scroll", (e) =>
        @onScroll()
        window.clearTimeout timeout
        timeout = window.setTimeout =>
          @onScrollEnd()
        , if @data.support then 10 else 300
      )

      $(window).on "keydown", _.bind(@onKey, this)

      timeout = window.setTimeout =>
        @onScrollEnd()
        @onResize()
      , 1

    onResize: ->
      @inactive = $(window).width() < 600 or $(window).height() < 720

      if @inactive
        @$elements.items.addClass("active")
        @$el.children().addClass("active")
        @$("[data-view]").trigger("show")

    onScroll: ->
      return if @inactive

      i  = Math.floor @el.scrollTop / @el.offsetHeight
      i2 = Math.floor @el.scrollTop / @el.offsetHeight + 0.5
      t1 = (@el.scrollTop / @el.offsetHeight) % 1
      t2 = Math.sin(Math.PI * t1)

      unless @data.support
        window.clearTimeout(@timeout)
        @timeout = window.setTimeout =>
          index = Math.round @el.scrollTop / @el.offsetHeight
          @el.scrollTo top: index * @el.offsetHeight, behavior: 'smooth'
        , 40

      w  = 120
      r  = 10

      ow = w + r
      iw = w - r * 2

      i  -= @data.min

      i2 = Math.max(Math.min(i2, @data.max), @data.min)

      x = if t1 > 0.5 then (1-t2) else 0
      w = if t1 < 0.5 then (t2) else 1

      @$elements.items.removeClass("active").eq(i2).addClass("active")

      @$elements.index.html(i2 + @data.offset)
      @$elements.pager.css "transform": "translateX(#{i * 100}%)"

      @$elements.pager.children().eq(0).css
        "transform": "translate3d(#{x * (ow / r * 100)}%, 0, 0)"

      @$elements.pager.children().eq(1).css
        "transform": "translate3d(#{x * (ow / iw * 100)}%, 0, 0) scale(#{1 + (t2 * (ow / iw))}, 1)"

      @$elements.pager.children().eq(2).css
        "transform": "translate3d(#{w * ((ow) / r) * 100}%, 0, 0)"

    onKey: (e) ->
      type = keycode(e)
      height = @el.offsetHeight
      index = Math.round @el.scrollTop / height

      if type is "UP" or type is "LEFT"
        e.preventDefault()
        @el.scrollTo top: (index - 1) * height, behavior: 'smooth'

      if type is "DOWN" or type is "RIGHT"
        e.preventDefault()
        @el.scrollTo top: (index + 1) * height, behavior: 'smooth'

    onScrollEnd: ->
      return if @inactive

      index = Math.floor @el.scrollTop / @el.offsetHeight + 0.5
      isEnd = @el.scrollTop % @el.offsetHeight is 0

      if index isnt @data.i
        $("body")
          .removeClass("page-#{@data.i}")
          .addClass("page-#{index}")

        _.extend @data,
          y: @el.scrollTop
          h: @el.offsetHeight
          i: index

       if isEnd
        for child, i in @el.children
          child.classList.toggle("active", i is @data.i)

          $("[data-view]", child).trigger(
            if i is @data.i then "show" else "hide"
          )


        window.ga?("send", "event", "Scroller", "show", document.title, index)

  module.exports = ScrollerView
