require.register "page-methods", (exports, require, module) ->
  
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
