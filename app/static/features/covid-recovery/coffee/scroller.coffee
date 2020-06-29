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

      @$elements =
        pager: $(@$el.data("pager"))
        index: $(@$el.data("index"))
        items: $(".pager-item")

      @listenTo this, "resize", @onResize

      timeout = null

      @$el.on("scroll", (e) =>
        @onScroll()
      )

      $(window).on "keydown", _.bind(@onKey, this)

      timeout = window.setTimeout =>
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

      scrollProgress = @el.scrollTop / (@el.scrollHeight - @el.clientHeight)
      @$elements.pager.css
        "transform": "scale3d(#{scrollProgress}, 1, 1)"

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

  module.exports = ScrollerView
