require.register "views/scroller", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")
  keycode  = require("lib/keycode")
  methods  = require("page-methods")
  
  SANDBOX = 6

  class ScrollerView extends Backbone.View
    events:
      "show": "onShow"
      "hide": "onHide"

    initialize: ->
      
      @$el.show()
      @data = _.extend {min: 0, max: 1000, offset: 1}, @$el.data()
      @slidePoints = $('.slide-wrap').map (i,s) -> s.offsetTop

      @data.support = window.CSS?.supports("scroll-snap-type: y mandatory")

      @$elements =
        pager: $(@$el.data("pager"))
        index: $(@$el.data("index"))
        items: $(".slide-wrap")

      @listenTo this, "resize", @onResize

      timeout = null

      @$el.on("scroll", (e) => 
        @onScroll() 
        # call onScrollEnd() once no scroll events
        # are heard for 10ms (or 300ms if not supported)
        window.clearTimeout timeout
        timeout = window.setTimeout =>
          @onScrollEnd()
        , if @data.support then 10 else 300
      )

    onResize: ->
      @inactive = false
      @mobile = true # $(window).width() < 600
                     # setting mobile to true to set slide indices
                     # at .slide-wrap entry points, rather than i * 100vh
      
      @slidePoints = $('.slide-wrap').map (i,s) -> s.offsetTop

      if @inactive
        @$elements.items.addClass("active")
        @$el.children().addClass("active")
        @$("[data-view]").trigger("show")

    onScroll: ->
      
      return if @inactive

      t = @el.scrollTop
      h = @el.offsetHeight
      index = @data.index
      
      @slidePoints.each (i,p) ->
        if p > t and p < t+h
          if p < t + 0.5*h
            index = i
          else
            index = i - 1

      # unless @data.support
      #   window.clearTimeout(@timeout)
      #   @timeout = window.setTimeout =>
      #     # index = Math.round @el.scrollTop / @el.offsetHeight
      #     # @el.scrollTo top: index * @el.offsetHeight, behavior: 'smooth'
      #   , 40

      @$elements.items.removeClass("active").eq(index).addClass("active")
      
      if index? and index isnt @data.index
        @updateSlide(@data.index, index)
        console.log index
      
    # update index if the top of a new .slide-wrap
    # container is in the top 50% of the screen
    updateSlide: (p,i) ->
      
      #---- CHART INTERACTIONS ----#
      
      if p is SANDBOX then methods.clearSandbox() # if leaving sandbox, clear it
      methods.deactivate()                                  # hide all country lines in any case
      if i is SANDBOX then methods.fillSandbox()        # if landing on sandbox, fill it

      if @data.index is "#pager-index" then @data.index = 0
      targetChart = $(".slide-wrap:nth-child(#{i+1}) .chart-body")
      targetChart?.append $("#chart-countries"), $("#country-labels")
        
      #------------------------------#
      
      $("body")
        .removeClass("slide-#{@data.index}")
        .addClass("slide-#{i}")

      _.extend @data,
        y: @el.scrollTop
        h: @el.offsetHeight
        index: i

    onScrollEnd: ->

      t = @el.scrollTop
      isEnd = t % @data.h is 0

      if isEnd
      
        for child, i in @el.children
          visible = i - 1 <= @data.index <= i + 1
          child.classList.toggle("active", i is @data.index)
          child.classList.toggle("hidden", not visible)
      
          if visible
            $("[data-view]", child).trigger("setup")
      
        window.ga?("send", "event", "Scroller", "show", document.title, index)

    scrollTo: (i) ->
      @el.scrollTo top: (i) * @el.offsetHeight, behavior: 'smooth'

  module.exports = ScrollerView
