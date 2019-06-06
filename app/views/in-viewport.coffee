class InView extends Backbone.View
  initialize: ->
    window.setTimeout(_.bind(@setup, this), 300)

  setup: ->
    observer = new IntersectionObserver (entries) =>
      entries.forEach (entry) =>
        if (entry.intersectionRatio > 0)
          @$el.addClass("visible").trigger("enter")
        else
          @$el.removeClass("visible").trigger("exit")

    observer.observe(@el)


module.exports = InView
