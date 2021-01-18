require.register "views/path", (exports, require, module) ->
  
  easie   = require "lib/easie"
  methods = require "page-methods"
  phrases = require "data/text"
  

  class PathView extends Backbone.View
    events:
      "click": "click"
      "mouseover": "append"

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
