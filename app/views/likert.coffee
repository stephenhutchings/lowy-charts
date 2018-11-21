class LikertView extends Backbone.View
  events:
    "mouseenter rect": "onEnter"
    "mouseleave rect": "onExit"

  onEnter: (e) ->
    { value, percent, target } = e.currentTarget.dataset

    @$target = @$(target)
    @default = @$target.text()
    t = @$target.text(percent)
    @$(e.currentTarget)
      .addClass("rect-hover")
      .parent()
      .addClass("group-hover")
      .siblings()
      .stop().animate({opacity: 0.5}, 300)

    @$target.siblings("text")
      .stop().animate({opacity: 0}, 300)

  onExit: ->
    @$target.text @default

    @$("g").stop().animate({opacity: 1}, 300)
    @$(".rect-hover, .group-hover").removeClass("rect-hover group-hover")

    @$target.siblings("text").stop().animate({opacity: 1}, 300)

module.exports = LikertView
