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
  tooltip   = get "#tooltip"
  
  # State
  vh = document.documentElement.clientHeight

  # Events
  body.addEventListener 'click', (e) -> methods.deactivate()
  chartArea.forEach (el) -> el.addEventListener 'click', (e) -> e.stopPropagation()
  countries.forEach (el) -> el.addEventListener 'mouseover', (e) -> tooltip.innerText = this.dataset.name
