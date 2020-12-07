require.register "page-methods", (exports, require, module) ->
  
  phrases      = require "data/text"
  TextScramble = require "TextScramble"
  
  get = (s) -> document.querySelector s
  getAll = (s) -> document.querySelectorAll s
  
  typeWrap = get "#type-wrap"
  scramble = 
    h: new TextScramble( get "#type-wrap h1" )
    b: new TextScramble( get "#type-wrap p"  )
    
  module.exports =
    
    deactivate: ->
      a = document.querySelector ".pathset.active"
      if not a? then return
      
      p = a.parentElement
      s = p.querySelectorAll '.inactive' # Sibling lines
      
      a.classList.remove 'active'
      s.forEach (e) -> e.classList.remove 'inactive'
      
      tooltip.innerText = ""
      
      @hideActiveCountries()
      
    hideActiveCountries: -> 
      c = document.querySelectorAll '.country-line.active'
      c.forEach (p) -> p.classList.remove('active')
      
    updateText: (i) ->
      active = getAll(".line-chart-wrap")[i]
      if active?
        id = active.dataset.name
        # typeWrap.classList.add "opacity-0"
        scramble.h.set(phrases[id].head)
        scramble.b.set(phrases[id].body)
          # .then () -> typeWrap.classList.remove "opacity-0"
      
    
    
