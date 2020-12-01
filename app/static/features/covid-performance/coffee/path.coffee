require.register "views/path", (exports, require, module) ->
  easie = require("lib/easie")
  active = null
  
  interpolate = (x, y, p) ->
    [
      x[0] + (y[0] - x[0]) * p
      x[1] + (y[1] - x[1]) * p
    ]

  class PathView extends Backbone.View
    events:
      "enter": "enter"
      "exit": "exit"
      "click": "click"

    initialize: (@data) ->
      
      @data.delay    ?= 0
      @data.duration ?= 2000
      @data.active   ?= false
      
      cat = @data.el.dataset.category
      val = @data.el.dataset.specifier
      
      @data.countries = [...$("[data-#{cat}=\"#{val}\"]")]
      

    exit: ->
      
      @data.countries.map( (d) -> d.style.opacity = 0 )
      
    activate: (e) ->
      
      if active? then @deactivate(active) # Remove current active
      
      p = e.parentElement
      p.appendChild(e) # Move line to top layer
      p.querySelectorAll('g').forEach( (g) -> if g isnt e then g.classList.add('inactive') ) # Dim siblings
      
      @data.countries.map( (d) -> d.classList.add('active') ) # Show country paths
      
      e.classList.add('active')
      
      active = e
      
      
    deactivate: (e) ->
      
      p = e.parentElement
      e.classList.remove('active')
      p.querySelectorAll('.inactive').forEach( (g) -> g.classList.remove('inactive') ) # Reactivate siblings
      
      @data.countries.map( (d) -> d.classList.remove('active') ) # Hide country paths
      
      active = null
      
      
    click: ->
      
      
      e = @data.el
      a = @data.active
      
      if a then @deactivate(e) else @activate(e)
      
      console.log active
      
      @data.active = not a
      


  module.exports = PathView
