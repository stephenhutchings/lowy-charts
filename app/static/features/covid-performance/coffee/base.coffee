$(document).ready =>
  
  methods = require "page-methods"
  
  # Functions
  get    = (s) -> document.querySelector s
  getAll = (s) -> document.querySelectorAll s
  
  # Elements
  body  = document.body
  chartWrap = get "#chart-wrap"
  chartArea = getAll ".line-chart-wrap"
  countries = getAll ".country-line.transparent"
  sandbox   = get ".sandbox"
  tooltip   = get "#tooltip"
  modalBtn  = get "#modal .btn-close"
  
  # State
  vh = document.documentElement.clientHeight

  # Events
  body.addEventListener 'click', (e) -> methods.deactivate()
  sandbox.addEventListener 'click', (e) -> e.stopPropagation()
  chartArea.forEach (el) -> el.addEventListener 'click', (e) -> e.stopPropagation()
  
  countries.forEach (el) -> 
    el.addEventListener 'mouseenter', (e) -> 
      label = get ".slide-wrap:not(.sandbox) [data-countrylabel=\"#{el.dataset.name}\"]"
      label?.classList.add "visible"
      
  countries.forEach (el) -> 
    el.addEventListener 'mouseleave', (e) -> 
      label = get ".slide-wrap:not(.sandbox) [data-countrylabel=\"#{el.dataset.name}\"]"
      label?.classList.remove "visible"

  modalBtn.addEventListener 'click', (e) -> 
    modalBtn.parentElement.classList.toggle 'active'
    e.stopPropagation()
