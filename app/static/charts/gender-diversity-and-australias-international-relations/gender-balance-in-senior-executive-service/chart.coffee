require.register "views/chart", (exports, require, module) ->
  { colors, font } = require("data/theme")

  utils = require("lib/utils")

  module.exports =
    class Chart extends Backbone.View
      data: window.chart
      events:
        "input select": "onSelection"
        "click .btn-l": "onPrev"
        "click .btn-r": "onNext"

      onPrev: (e) ->
        $opts = @$("select option")
        index = @$(":selected", $opts).index() - 1
        index = $opts.length - 1 if index < 0

        $opts.parent().val($opts.eq(index).val()).trigger("input")

      onNext: (e) ->
        $opts = @$("select option")
        index = @$(":selected", $opts).index() + 1
        index = 0 if index > $opts.length - 1

        $opts.parent().val($opts.eq(index).val()).trigger("input")

      onSelection: (e) ->
        @render +e.target.value

      render: (index) ->
        @$("[data-values]").each (i, el) ->
          $el = $(el)
          fn  = $el.data("method")
          val = $el.data("values")[index]
          $el[fn](val)
