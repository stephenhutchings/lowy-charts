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
        , if @data.support then 10 else 300
      )

      timeout = window.setTimeout =>
        $(window).on "keydown", _.bind(@onKey, this)

        @onScrollEnd()
        @onResize()
      , 1

    onResize: ->
      @inactive = false
      @mobile = $(window).width() < 600
      
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
      
      if @mobile
        @slidePoints.each (i,p) -> 
          if p > t and p < t+h
            if p < t + 0.5*h then index = i
            else index = i - 1
      
      else 
        index = Math.floor t / h + 0.5
        
      isEnd = t % h is 0
      

      if index isnt @data.index
        
        console.log index
        
        #---- CHART INTERACTIONS ----#
        
        if @data.index is "#pager-index" then @data.index = 0
        targetChart = $(".slide-wrap:nth-child(#{index+1}) .chart-body")
        targetChart?.append $("#chart-countries"), $("#country-labels")
          
        if @data.index is SANDBOX then methods.clearSandbox()
        methods.deactivate()
        if index is SANDBOX then methods.fillSandbox()
        
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

    onFS: ->
      document.body.requestFullscreen?().then =>
        index = Math.floor @el.scrollTop / @el.offsetHeight + 0.5

        @scrollTo(index)

    setScale: ->
      if document.fullscreenElement
        ws = window.innerWidth / 1280
        hs = window.innerHeight / 720
        scale = Math.min ws, hs

      @el.style.transform = if scale then "scale(#{scale}) translateZ(0)" else ""


  module.exports = ScrollerView
