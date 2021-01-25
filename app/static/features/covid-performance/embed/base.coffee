get = (s) -> document.querySelector s
getAll = (s) -> document.querySelectorAll s
  
countries = getAll ".country-line.transparent"

console.log('afhjkdsgh')

# More events
countries.forEach (el) -> 
  el.addEventListener 'mouseenter', (e) -> 
    label = get "[data-countrylabel=\"#{el.dataset.name}\"]"
    label?.classList.add "visible"
    
countries.forEach (el) -> 
  el.addEventListener 'mouseleave', (e) -> 
    label = get "[data-countrylabel=\"#{el.dataset.name}\"]"
    label?.classList.remove "visible"
