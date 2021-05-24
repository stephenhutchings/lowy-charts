const ASPECT_RATIO = 954 / 895.5

var vh
var map = document.querySelector('#map')

const china = document.querySelectorAll('#China, [data-name=china]')
const brunei = document.querySelectorAll('#Brunei, [data-name=brunei]')
const vietnam = document.querySelectorAll('#Vietnam, [data-name=vietnam]')
const malaysia = document.querySelectorAll('#Malaysia, [data-name=malaysia]')
const indonesia = document.querySelectorAll('#Indonesia, [data-name=indonesia]')
const philippines = document.querySelectorAll('#Philippines, [data-name=philippines]')

const maintainAspectRatio = h => map.style.width = ASPECT_RATIO * h + 'px'

const update = () => {
  vh = window.innerHeight
  let bb = map.getBoundingClientRect()
  let overflow = vh - bb.top + bb.height
  if (overflow > 0) {
    maintainAspectRatio(vh - bb.top)
  } else if (overflow < 0) {
    map.removeAttribute('style')
  }
}

const toggle = (country, btn) => {
  btn.classList.toggle('active')
  country.forEach(c => c.classList.toggle('opacity-0'))
}

window.onload = update
window.addEventListener("resize", update)
