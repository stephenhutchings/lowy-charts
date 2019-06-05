require.register "views/type", (exports, require, module) ->
  easie = require("lib/easie")

  class TypeView extends Backbone.View
    events:
      "enter": "enter"
      "exit": "exit"

    initialize: (@data) ->
      @data.duration ?= 2000
      @data.delay ?= 0
      window.setTimeout _.bind(@setup, this), 20

    setup: ->
      width = 0

      empty = ([0..4]).reduce ((m)-> m + "\u200b"), ""

      @lines = ({$el: $(el)} for el in @$(".line").toArray())

      for line in @lines
        line.text = line.$el.text()
          .replace(/([:,])( |$)/g, "$1#{empty}#{empty}$2")
          .replace(/([\.;])( |$)/g, "$1#{empty}#{empty}#{empty}$2")
          .replace(new RegExp("#{empty} (\\w+),","g"), " $1,")

        width = Math.max(width, line.$el.outerWidth())
        line.$el.width(line.$el.width())
        line.$el.html("&nbsp;")
        line.$el.addClass("hide")

      @$el.width(~~width)
      @exit()

    enter: ->
      return unless @lines or @interval

      int   = null
      count = 0
      total = @lines.reduce ((m, e)-> m + e.text.length), 0

      window.clearInterval(@interval)
      @$el.removeClass("complete")

      for line in @lines
        line.$el.addClass("hide")
        line.$el.html("<div class='line-bg' />")
        line.$el.find(".line-bg").css("transition-duration": ~~(line.text.length * @data.duration / total) + "ms")

      # Chance of glitching
      chance = 0.99 + total / 15000

      repeat = =>
        if count <= total + 1
          run = 0
          for line, j in @lines
            if run+1 is count
              line.$el.removeClass("hide")
            if run < count <= run + line.text.length
              e = line.text.slice(count - run - 1)[0]
              e = if e is " " then "&nbsp;" else e
              c = if e.match(/(\u200b)/) then [] else ["char"]
              c.push("last") if count is run + line.text.replace(/(\u200b)+$/,"").length

              if u = _.find(@data.underline, {row: j})
                c.push("underline") if u.start < (count-run) <= u.end
                c.push("ul-first")  if u.start is (count-run) - 1
                c.push("ul-last")   if u.end is (count-run)

              line.$el.append """<span class="#{c.join(" ")}"
                data-title="#{e}">#{e}</span>"""
            if count is run + line.text.length + 1
              line.$el.append "<span class=\"end\"></span>"

            run += line.text.length

        else
          @$el.addClass("complete")

          unless @data.glitch
            window.clearInterval(@interval)
            delete @interval

        if @data.glitch
          for el, i in @$(".char").toArray()
            if Math.random() > chance #and count < total
              el.innerHTML = _.sample("xqvk0!")
              el.classList.add("glitch")
            else if Math.random() > chance*.8 #or count is total
              el.classList.remove("glitch")
              el.innerHTML = el.dataset.title

        count++

      @interval = window.setInterval(repeat, @data.duration / total)

    exit: ->
      return unless @lines
      @$el.removeClass("complete")
      line.$el.addClass("hide") for line in @lines


  module.exports = TypeView
