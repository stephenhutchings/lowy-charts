require.register "page-methods", (exports, require, module) ->
  
  get = (s) -> document.querySelector s
  getAll = (s) -> document.querySelectorAll s
  
  typeWrap = get "#type-wrap"
    
  module.exports =

    deactivate: ->
      
      a = get ".pathset.active"
      if a?
      
        p = a.parentElement
        s = p.querySelectorAll '.inactive' # Sibling lines
        
        a.classList.remove 'active'
        s.forEach (e) -> e.classList.remove 'inactive'
      
      get('#modal').classList.remove('active')
      get('#modal-inner').scrollTop = 0
      
      $('.rankings').removeClass('hidden')           # Reshow table of averages
      $('.click-instruction').removeClass('hidden')  # Reshow instruction
            
      @hideActiveCountries()
      
    hideActiveCountries: -> 
      
      c = getAll '.country-line.active'
      c.forEach (p) -> p.classList.remove('active')
        
      l = getAll '.country-line-label.visible'
      l.forEach (p) -> p.classList.remove('visible')
    
    clearSandbox: -> 
      
      c = getAll '.country-line.active'
      c.forEach (p) -> 
        p.style.removeProperty('stroke')
        p.classList.remove('thicker')
        
      l = getAll '.country-line-label.visible'
      l.forEach (p) -> p.style.removeProperty('color')
    
    fillSandbox: -> 
      
      c = getAll '.remove-option'
      c.forEach (p) -> 
        name  = p.innerText.trim()
        color = window.getComputedStyle(p).getPropertyValue('background-color')
        lines = getAll ".country-line[data-name=\"#{name}\"]"
        label = get ".country-line-label[data-countrylabel=\"#{name}\"]"
        
        label.classList.add 'visible'
        lines.forEach (l) -> l.classList.add 'thicker', 'active'

        lines[1].style.stroke = label.style.color = color
    
    
