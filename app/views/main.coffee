app      = require "app"
keycode  = require("lib/keycode")

class MainView extends Backbone.View
  initialize: ->
    $target = $(window)
    timeouts = {}

    if window.parent is window
      $(".wrapper").css(margin: "20px auto")

    for evt in ["scroll", "resize"]
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

        $target.on evt, _debounced

    @views =
      @$("[data-view]").map((i, el) =>
        view = $(el).data("view")
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
