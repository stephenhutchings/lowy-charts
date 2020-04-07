# This small view controls the scroll snapping and animates the bar on the
# issue page footer.

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
      @inactive = $(window).width() < 800 or $(window).height() < 720

      if @inactive
        @$elements.items.addClass("active")
        @$el.children().addClass("active")
        @$("[data-view]").trigger("show")

    onScroll: ->
      return if @inactive

      adjust = 1.5
      scrollProgress = 100 * @el.scrollTop / (@el.scrollHeight - @el.clientHeight)
      @$elements.pager.css "width": "#{scrollProgress - adjust}%"

      unless @data.support
        window.clearTimeout(@timeout)
        @timeout = window.setTimeout =>
          index = Math.round @el.scrollTop / @el.offsetHeight
          @el.scrollTo top: index * @el.offsetHeight, behavior: 'smooth'
        , 40

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
