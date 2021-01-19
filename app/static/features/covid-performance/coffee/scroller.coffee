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

      @data.support = window.CSS?.supports("scroll-snap-type: y mandatory")

      @$elements =
        pager: $(@$el.data("pager"))
        index: $(@$el.data("index"))
        items: $(".pager-item")
        
      $("#pager-total").html($('.slide-wrap').length)

      @listenTo this, "resize", @onResize
      $(document.body).on "fullscreenchange", _.bind(@setScale, this)

      $("#btn-prev").click (e) => @scrollTo(@data.index - 1)
      $("#btn-next").click (e) => @scrollTo(@data.index + 1)
      $("#btn-fs").click (e) => @onFS(e)

      timeout = null

      @$el.on("scroll", (e) =>
        @onScroll()
        window.clearTimeout timeout
        timeout = window.setTimeout =>
          @onScrollEnd()
        , if @data.support then 30 else 300
      )

      timeout = window.setTimeout =>
        $(window).on "keydown", _.bind(@onKey, this)

        @onScrollEnd()
        @onResize()
      , 1

    onResize: ->
      @inactive = false
      @mobile = true # $(window).width() < 600
                     # setting mobile to true to set slide indices
                     # at .slide-wrap entry points, rather than i * 100vh
      
      if @mobile
        @slidePoints = $('.slide-wrap').map (i,s) -> s.offsetTop

      if @inactive
        @$elements.items.addClass("active")
        @$el.children().addClass("active")
        @$("[data-view]").trigger("show")

    onScroll: ->
      return if @inactive

      i  = Math.floor @el.scrollTop / @el.offsetHeight + 0.5
      
      # console.log @el.scrollTop, @el.offsetHeight

      unless @data.support
        window.clearTimeout(@timeout)
        @timeout = window.setTimeout =>
          index = Math.round @el.scrollTop / @el.offsetHeight
          @el.scrollTo top: index * @el.offsetHeight, behavior: 'smooth'
        , 40

      @$elements.items.removeClass("active").eq(i).addClass("active")
      @$elements.index.html(i + @data.offset)      

    onKey: (e) ->
      type = keycode(e)
      height = @el.offsetHeight
      index = Math.round @el.scrollTop / height

      if type is "UP" or type is "LEFT"
        e.preventDefault()
        @el.scrollTo top: (index - 1) * height, behavior: 'smooth'

      if type is "DOWN" or type is "RIGHT"
        e.preventDefault()
        @el.scrollTo top: (index + 1) * height, behavior: 'smooth'

    scrollTo: (i) ->
      @el.scrollTo top: (i) * @el.offsetHeight, behavior: 'smooth'

    onScrollEnd: ->
      return if @inactive
      
      t = @el.scrollTop
      h = @el.offsetHeight
      index = @data.index
      
      # update index if the top of a new .slide-wrap
      # container is in the top 50% of the screen
      if @mobile
        @slidePoints.each (i,p) ->
          if p > t and p < t+h
            if p < t + 0.5*h then index = i
            else index = i - 1
      
      else 
        index = Math.floor t / h + 0.5
        
      isEnd = t % h is 0
      

      if index isnt @data.index
        
        #---- CHART INTERACTIONS ----#
        
        if @data.index is SANDBOX then methods.clearSandbox() # if leaving sandbox, clear it
        methods.deactivate()                                  # hide all country lines in any case
        if index is SANDBOX then methods.fillSandbox()        # if landing on sandbox, fill it

        if @data.index is "#pager-index" then @data.index = 0
        targetChart = $(".slide-wrap:nth-child(#{index+1}) .chart-body")
        targetChart?.append $("#chart-countries"), $("#country-labels")
          
        #------------------------------#
        
        $("body")
          .removeClass("slide-#{@data.index}")
          .addClass("slide-#{index}")

        _.extend @data,
          y: @el.scrollTop
          h: @el.offsetHeight
          index: index
          
       if isEnd
         
        for child, i in @el.children
          visible = i - 1 <= @data.index <= i + 1
          child.classList.toggle("active", i is @data.index)
          child.classList.toggle("hidden", not visible)

          if visible
            $("[data-view]", child).trigger("setup")


        window.ga?("send", "event", "Scroller", "show", document.title, index)

    setScale: ->
      if document.fullscreenElement
        ws = window.innerWidth / 1280
        hs = window.innerHeight / 720
        scale = Math.min ws, hs

      @el.style.transform = if scale then "scale(#{scale}) translateZ(0)" else ""


  module.exports = ScrollerView
