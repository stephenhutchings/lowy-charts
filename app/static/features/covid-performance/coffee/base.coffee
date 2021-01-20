$(document).ready =>
  
  methods = require "page-methods"
  
  # Functions
  get    = (s) -> document.querySelector s
  getAll = (s) -> document.querySelectorAll s
  navTog = (e) -> nav.classList.toggle 'open'; navBtn.classList.toggle 'open'; e.stopPropagation();
  navCls = ()  -> nav.classList.remove 'open'; navBtn.classList.remove 'open';
  fold = (d,n) -> 
    # fold div 'd' to show first 'n' paragraphs only.
    plist  = d.querySelectorAll('p')
    offset = plist[0].offsetTop
    target = plist[n].offsetTop
    d.style.maxHeight = target - offset + "px"; 
    
  unfold = (d, btn) -> 
    plist  = d.querySelectorAll('p')
    target = plist[ plist.length - 1 ]
    d.style.maxHeight = target.offsetTop + target.offsetHeight + "px"
    btn.style.display = 'none'
    
  # Elements
  body  = document.body
  chartWrap = get "#chart-wrap"
  chartArea = getAll ".line-chart-wrap"
  countries = getAll ".country-line.transparent"
  sandbox   = get ".sandbox"
  tooltip   = get "#tooltip"
  overview  = get '#overview-body'
  ovrvwBtn  = get '#overview-body .btn-down'
  modalBtn  = get "#modal .btn-down"
  navBtn    = get "#btn-nav"
  navLks    = getAll "nav a"
  nav       = get "nav"
  
  # Window sizes
  vh = vw = mobile = 0
  onResize = () ->
    vh = document.documentElement.clientHeight
    vw = document.documentElement.clientWidth
    mobile = vw < 600
    
  # Onload actions
  fold(overview, 2)

  # Events
  onResize()
  window.addEventListener 'resize', (e) -> onResize()
  body.addEventListener 'click', (e) -> methods.deactivate()
  ovrvwBtn.addEventListener 'click', (e) -> unfold(overview, ovrvwBtn)
  sandbox.addEventListener 'click', (e) -> e.stopPropagation()
  navBtn.addEventListener 'click', (e) -> navTog(e)
  chartArea.forEach (el) -> el.addEventListener 'click', (e) -> e.stopPropagation()
  
  # More events
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
