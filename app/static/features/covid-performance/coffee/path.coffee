require.register "views/path", (exports, require, module) ->
  
  easie   = require "lib/easie"
  methods = require "page-methods"
  phrases = require "data/text"
  

  class PathView extends Backbone.View
    events:
      "click": "click"
      "mouseover": "append"
      "mouseenter": "hover"
      "mouseleave": "hoveroff"

    initialize: (@data) ->
      
      @data.delay    ?= 0
      @data.duration ?= 2000
      
      @cat = @data.el.dataset.category
      @val = @data.el.dataset.specifier
      
      @data.countries = [...$("[data-#{@cat}=\"#{@val}\"]")]
      
    append: (event, e, p) ->
      # Move line to top layer
      e ?= @data.el
      p ?= e.parentElement
      p.appendChild e
      
    hover: (event) ->
      # Hide neighbouring pathsets
      e = @data.el
      e.parentElement
        .querySelectorAll('.pathset').forEach (el) ->
          if el isnt e then el.classList.add('dimmed')
        
    hoveroff: (event) ->
      # Show neighbouring pathsets
      e = @data.el
      e.parentElement
        .querySelectorAll('.dimmed').forEach (el) ->
          if el isnt e then el.classList.remove('dimmed')
      
    activate: (ev) ->
      
      e = @data.el
      p = e.parentElement
      
      p.querySelectorAll('g').forEach (g) -> if g isnt e then g.classList.add('inactive') # Dim siblings
      
      @data.countries.map (d) -> d.classList.add('active') # Show country paths
      $('.rankings').addClass('hidden')  # Hide table of averages
      
      e.classList.add 'active'
      
      $('#modal-inner .name').html(phrases[@cat][@val].name)
      $('#modal-inner .text').html(phrases[@cat][@val].text)
      $('#modal').addClass('active')
      
    click: (ev) ->
      
      e = @data.el
      active = document.querySelector ".pathset.active"
      
      if active? then methods.deactivate()
      if e isnt active then @activate(e)
      
      ev.stopPropagation()


  module.exports = PathView
