
# Elements
countryPaths = document.querySelectorAll '.country-line'

# Events
document.querySelector("#frame").addEventListener('click', hideCountries)

hideCountries = () ->
  countryPaths.forEach( (e) -> e.style.opacity = 0 )
  console.log "Hiding countries"
  
