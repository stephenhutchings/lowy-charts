require.register "views/page", (exports, require, module) ->
  keycode  = require("lib/keycode")

  class PageView extends Backbone.View
    events:
      "enter": "enter"
      "exit": "exit"

    initialize: (@data) ->
      @data.index ?= 0
      @data.pages ?= 0

      @$el.addClass("page-#{@data.index}")

      $(window).on "keydown", _.bind(@onKeyPress, this)
      $("body").focus()

    enter: ->
      @data.active = true
      @$el.addClass("page-#{@data.index}")

    exit: ->
      @data.active = false
      @$el.removeClass("page-#{@data.index}")

    update: ->
      @$("[data-attributes]").each (i, el) =>
        $el   = $(el)
        attrs = $el.data("attributes")
        $el.attr(attrs[@data.index])

    onKeyPress: (e) ->
      if @data.active
        code = keycode(e)
        prev = @data.index

        if (code is "UP" or code is "LEFT") and 0 < @data.index
          @data.index--

        if (code is "DOWN" or code is "RIGHT") and @data.index < @data.pages - 1
          @data.index++

        if prev isnt @data.index
          e.preventDefault()
          e.stopImmediatePropagation()
          @$el
            .removeClass("page-#{prev}")
            .addClass("page-#{@data.index}")

        @update()

      return


  module.exports = PageView
