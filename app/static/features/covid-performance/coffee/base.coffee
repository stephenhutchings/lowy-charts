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
    body.classList.add('slide-1')
    body.classList.remove('slide-2')
    
  # Elements
  body  = document.body
  chartWrap = get "#chart-wrap"
  chartArea = getAll ".line-chart-wrap"
  countries = getAll ".country-line.transparent"
  sandbox   = get ".sandbox"
  tooltip   = get "#tooltip"
  overview  = get '#overview-body'
  ovrvwBtn  = get '#overview-body .btn-down'
  modal     = get "#modal"
  modalInn  = get "#modal-inner"
  modalBtn  = get "#modal .btn-down"
  nav       = get "nav"
  navBtn    = get "#btn-nav"
  navLks    = getAll "nav a"
  embBtns   = getAll ".btn-embed"
  embWrps   = getAll ".embed-items"
  
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
  body.addEventListener 'click', (e) -> if not body.classList.contains('slide-7') then methods.deactivate()
  ovrvwBtn.addEventListener 'click', (e) -> unfold(overview, ovrvwBtn)
  ovrvwBtn.addEventListener 'touch', (e) -> unfold(overview, ovrvwBtn)
  modalInn.addEventListener 'click', (e) -> e.stopPropagation()
  sandbox.addEventListener 'click', (e) -> e.stopPropagation()
  navBtn.addEventListener 'click', (e) -> navTog(e)
  chartArea.forEach (el) -> el.addEventListener 'click', (e) -> e.stopPropagation()
  
  # More events
  modalBtn.addEventListener 'click', (e) -> 
    modal.classList.remove('active')
    e.stopPropagation()
  
  countries.forEach (el) -> 
    el.addEventListener 'mouseenter', (e) -> 
      label = get ".slide-wrap:not(.sandbox) [data-countrylabel=\"#{el.dataset.name}\"]"
      label?.classList.add "visible"
      
  countries.forEach (el) -> 
    el.addEventListener 'mouseleave', (e) -> 
      label = get ".slide-wrap:not(.sandbox) [data-countrylabel=\"#{el.dataset.name}\"]"
      label?.classList.remove "visible"
    
  navLks.forEach (a) -> 
    a.addEventListener 'click', (e) -> if mobile then navCls()
    
  embBtns.forEach (el,i) -> 
    el.addEventListener 'click', (e) -> embWrps[i].classList.toggle 'open'
