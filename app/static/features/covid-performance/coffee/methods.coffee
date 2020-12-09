require.register "page-methods", (exports, require, module) ->
  
  get = (s) -> document.querySelector s
  getAll = (s) -> document.querySelectorAll s
  
  typeWrap = get "#type-wrap"
    
  module.exports =
    
    deactivate: ->
      a = document.querySelector ".pathset.active"
      if not a? then return
      
      p = a.parentElement
      s = p.querySelectorAll '.inactive' # Sibling lines
      
      a.classList.remove 'active'
      s.forEach (e) -> e.classList.remove 'inactive'
      
      tooltip.innerText = ""
      
      get('#modal').classList.remove('active')
      get('#modal-inner').scrollTop = 0
      
      @hideActiveCountries()
      
    hideActiveCountries: -> 
      c = document.querySelectorAll '.country-line.active'
      c.forEach (p) -> p.classList.remove('active')
    
    
