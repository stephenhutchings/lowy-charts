require.register "views/path", (exports, require, module) ->
  
  easie   = require "lib/easie"
  methods = require "page-methods"

  class PathView extends Backbone.View
    events:
      "click": "click"

    initialize: (@data) ->
      
      @data.delay    ?= 0
      @data.duration ?= 2000
      
      cat = @data.el.dataset.category
      val = @data.el.dataset.specifier
      
      @data.countries = [...$("[data-#{cat}=\"#{val}\"]")]
      
    activate: (e) ->
      
      p = e.parentElement
      p.appendChild e # Move line to top layer
      p.querySelectorAll('g').forEach (g) -> if g isnt e then g.classList.add('inactive') # Dim siblings
      
      @data.countries.map (d) -> d.classList.add('active') # Show country paths
      
      e.classList.add 'active'
      
    click: (ev) ->
      
      e = @data.el
      active = document.querySelector ".pathset.active"
      
      if active? then methods.deactivate()
      if e isnt active then @activate(e)
      
      ev.stopPropagation()


  module.exports = PathView
