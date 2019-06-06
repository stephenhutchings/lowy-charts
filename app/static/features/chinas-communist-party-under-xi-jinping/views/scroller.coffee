require.register "views/scroller", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")
  keycode  = require("lib/keycode")

  class ScrollerView extends Backbone.View
    events:
      "show": "onShow"
      "hide": "onHide"

    initialize: ->
      @$el.show()
      @data = _.extend {min: 0, max: 1000}, @$el.data()

      @data.support = window.CSS?.supports("scroll-snap-type: y mandatory")

      @$elements =
        pager: $(@$el.data("pager"))
        index: $(@$el.data("index"))
        items: $(".pager-item")

      @listenTo this, "resize", @onResize

      $("#btn-prev").click (e) => @onPrev(e)
      $("#btn-next").click (e) => @onNext(e)

      timeout = null

      @$el.on("scroll", (e) =>
        @onScroll()
        window.clearTimeout timeout
        timeout = window.setTimeout =>
          @onScrollEnd()
        , if @data.support then 10 else 300
      )

      timeout = window.setTimeout =>
        $(window).on "keydown", _.bind(@onKey, this)

        @onScrollEnd()
        @onResize()
      , 1

    onResize: ->
      @inactive = $(window).width() < 800 or $(window).height() < 720

      if @inactive
        @$elements.items.addClass("active")
        @$el.children().addClass("active")
        @$("[data-view]").trigger("show")

    onScroll: ->
      return if @inactive

      i  = Math.floor @el.scrollTop / @el.offsetHeight + 0.5

      unless @data.support
        window.clearTimeout(@timeout)
        @timeout = window.setTimeout =>
          index = Math.round @el.scrollTop / @el.offsetHeight
          @el.scrollTo top: index * @el.offsetHeight, behavior: 'smooth'
        , 40

      @$elements.items.removeClass("active").eq(i).addClass("active")
      @$elements.index.html(i + @data.offset)

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

    onPrev: ->
      index = Math.floor @el.scrollTop / @el.offsetHeight + 0.5
      @scrollTo(index - 1)

    onNext: ->
      index = Math.floor @el.scrollTop / @el.offsetHeight + 0.5
      @scrollTo(index + 1)

    scrollTo: (i) ->
      console.log i
      @$el.addClass("scrolling")
      @$el.scrollTo i * @el.offsetHeight, =>
        @$el.removeClass("scrolling")

    onScrollEnd: ->
      return if @inactive

      index = Math.floor @el.scrollTop / @el.offsetHeight + 0.5
      isEnd = @el.scrollTop % @el.offsetHeight is 0

      if index isnt @data.i
        $("body")
          .removeClass("slide-#{@data.i}")
          .addClass("slide-#{index}")

        _.extend @data,
          y: @el.scrollTop
          h: @el.offsetHeight
          i: index

       if isEnd
        for child, i in @el.children
          child.classList.toggle("active", i is @data.i)

        window.ga?("send", "event", "Scroller", "show", document.title, index)

  module.exports = ScrollerView
