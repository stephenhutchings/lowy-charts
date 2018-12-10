class MatchView extends Backbone.View
  events:
    "mouseenter [data-id]": "onEnter"
    "mouseleave [data-id]": "onLeave"

  initialize: ->
    @$elements = @$("[data-id]")
    @$links = @$("[data-link]")

  onEnter: (e) ->
    e.preventDefault()

    $a = $(e.currentTarget)
    id = $a.attr("data-id")

    @$links.removeClass("active")

    @$("[data-link='#{id}']").addClass("active")

    @$elements
      .not($a)
      .each (i, el) ->
        $b = $(el)
        bl = $b.attr("data-list")?.split(" ")
        $b.toggleClass("active", _.includes(bl, id))

    @$elements
      .filter(".active")
      .each (i, el) =>
        id = $(el).attr("data-id")
        @$("[data-link='#{id}']").addClass("active")

    $a.addClass("active")

  onLeave: ->
    @$elements.removeClass("active")
    @$links.removeClass("active")

module.exports = MatchView
