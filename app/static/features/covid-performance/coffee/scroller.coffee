require.register "views/scroller", (exports, require, module) ->
  easie = require("lib/easie")
  utils = require("lib/utils")
  keycode  = require("lib/keycode")
  methods  = require("page-methods")
  
  get = (s) -> document.querySelector s

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
      
      @mobile = $(window).width() < 600

      @$elements =
        pager: $(@$el.data("pager"))
        index: $(@$el.data("index"))
        items: $(".slide-wrap")

      @listenTo this, "resize", @onResize

      # Trigger resize when overview is unfolded (DOM height changes)
      @ovrvwBtn = $('#overview-body .btn-down')
      @ovrvwBtn.on("click", (e) => 
        window.setTimeout =>
          @onResize()
        , 510
      )
      
      timeout = null
      @$el.on("scroll", (e) => 
        @onScroll() 
        # call onScrollEnd() once no scroll events
        # are heard for 100ms (or 300ms if not supported)
        window.clearTimeout timeout
        timeout = window.setTimeout =>
          @onScrollEnd()
        , if @data.support then 100 else 300
      )

    onResize: ->
      
      @inactive = false
      @mobile = $(window).width() < 600
      
      console.log $(window).width()

      @slidePoints = $('.slide-wrap').map (i,s) -> s.offsetTop

      if @inactive
        @$elements.items.addClass("active")
        @$el.children().addClass("active")
        @$("[data-view]").trigger("show")

    onScroll: ->
      
      return if @inactive
      
      console.log 'Scrolling'

      t = @el.scrollTop
      h = @el.offsetHeight
      index = @data.index
      
      @slidePoints.each (i,p) ->
        if p > t and p < t+h
          if p < t + 0.5*h
            index = i
          else
            index = i - 1

      @$elements.items.removeClass("active").eq(index).addClass("active")
      
      if index isnt @data.index
        @updateSlide(@data.index, index)
      
    # update index if the top of a new .slide-wrap
    # container is in the top 50% of the screen
    updateSlide: (p,i) ->
      
      $("body")
        .removeClass("slide-#{@data.index}")
        .addClass("slide-#{i}")

      _.extend @data,
        y: @el.scrollTop
        h: @el.offsetHeight
        index: i
        
      #---- CHART INTERACTIONS ----#
      
      if p is SANDBOX then methods.clearSandbox() # if leaving sandbox, clear it
      methods.deactivate()                        # hide all country lines in any case
      if i is SANDBOX then methods.fillSandbox()  # if landing on sandbox, fill it

      if @data.index is "#pager-index" then @data.index = 0
      targetChart = $(".slide-wrap:nth-child(#{i+1}) .chart-body")
      targetChart?.append $("#chart-countries"), $("#country-labels")
        
      #------------------------------#
      
      #--- SLIDE-SPECIFIC ACTIONS ---#
      
      if p is 0 and not @mobile
        get('nav').classList.add 'open'
        get('#btn-nav').classList.add 'open';
        
      if i is 0 and not @mobile
        get('nav').classList.remove 'open'
        get('#btn-nav').classList.remove 'open';
        
      #------------------------------#
      

    onScrollEnd: ->

      t = @el.scrollTop
      isEnd = t % @data.h is 0
    
      console.log "ScrollEnd"

      if isEnd
      
        for child, i in @el.children
          visible = i - 1 <= @data.index <= i + 1
          child.classList.toggle("active", i is @data.index)
          # child.classList.toggle("hidden", not visible)
      
          if visible
            $("[data-view]", child).trigger("setup")
      
        window.ga?("send", "event", "Scroller", "show", document.title, index)

    scrollTo: (i) ->
      @el.scrollTo top: (i) * @el.offsetHeight, behavior: 'smooth'

  module.exports = ScrollerView
