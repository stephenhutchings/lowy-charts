$(document).ready =>
  
  methods = require "page-methods"
  
  # Functions
  get    = (s) -> document.querySelector s
  getAll = (s) -> document.querySelectorAll s
  
  # Elements
  body  = document.body
  chartArea = getAll ".line-chart-wrap"

  # Events
  body.addEventListener  'click', (e) -> methods.deactivate()
  
  chartArea.forEach (el) -> 
    el.addEventListener 'click', (e) -> e.stopPropagation()
