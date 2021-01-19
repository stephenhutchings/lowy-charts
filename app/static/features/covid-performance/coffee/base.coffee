$(document).ready =>
  
  methods = require "page-methods"
  
  # Functions
  get    = (s) -> document.querySelector s
  getAll = (s) -> document.querySelectorAll s
  navTog = (e) -> nav.classList.toggle 'open'; navBtn.classList.toggle 'open'; e.stopPropagation();
  navCls = ()  -> nav.classList.remove 'open'; navBtn.classList.remove 'open';
  
  # Elements
  body  = document.body
  chartWrap = get "#chart-wrap"
  chartArea = getAll ".line-chart-wrap"
  countries = getAll ".country-line.transparent"
  sandbox   = get ".sandbox"
  tooltip   = get "#tooltip"
  modalBtn  = get "#modal .btn-close"
  navBtn    = get "#btn-nav"
  navLks    = getAll "nav a"
  nav       = get "nav"
  
  # Window sizes
  vh = vw = mobile = 0
  onResize = () ->
    vh = document.documentElement.clientHeight
    vw = document.documentElement.clientWidth
    mobile = vw < 600

  # Events
  onResize()
  window.addEventListener 'resize', (e) -> onResize()
  body.addEventListener 'click', (e) -> methods.deactivate(); navCls();
  sandbox.addEventListener 'click', (e) -> e.stopPropagation()
  nav.addEventListener 'click', (e) -> e.stopPropagation()
  navBtn.addEventListener 'click', (e) -> navTog(e)
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
    
  navLks.forEach (a) -> 
    a.addEventListener 'click', (e) -> if mobile then navCls()
