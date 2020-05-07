app      = require "app"
keycode  = require("lib/keycode")

var Note = Backbone.Model.extend({

  initialize: function() { ... }

});

class MainView extends Backbone.View
  initialize: ->
    $target = $(window)
    timeouts = {}
    isEmbed  = window.parent isnt window

    @$el.addClass("embed-#{isEmbed.toString()}")

    if not isEmbed
      $wrapper = $(".wrapper")
      innerH = $wrapper.outerHeight()
      outerH = $("html").height()
      $wrapper.css(margin: "#{(outerH - innerH) / 2}px auto")

    @$("[data-src]").each (i, el) ->
      $el = $(el)
      $el.attr("src", $el.data("src"))

    for evt in ["resize"]
      do (evt, timeouts) =>
        _debounced = =>
          fn = =>
            @onDebouncedEvent(evt)
            delete timeouts[evt]

          if timeouts[evt]
            window.clearTimeout timeouts[evt]
          else
            window.setTimeout fn(), 0

          timeouts[evt] = window.setTimeout fn, 300
          return

        $target.on evt, _debounced

    @views =
      @$("[data-view]").map((i, el) =>
        views = $(el).data("view").split(/, */)
        for view in views
          try
            View = (require "views/#{view}")
            opts = _.extend { el }, $(el).data()
            new View(opts)
          catch err
            console.error "error making view views/#{view}", err

      ).toArray()

  onDebouncedEvent: (evt) ->
    view?.trigger(evt) for view in @views

module.exports = MainView
