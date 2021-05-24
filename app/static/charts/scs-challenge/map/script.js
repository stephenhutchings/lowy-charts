const ASPECT_RATIO = 895.5 / 954

var vw
var map = document.querySelector('#map')

const china = document.querySelector('#China')
const brunei = document.querySelector('#Brunei')
const vietnam = document.querySelector('#Vietnam')
const malaysia = document.querySelector('#Malaysia')
const indonesia = document.querySelector('#Indonesia')
const philippines = document.querySelector('#Philippines')

const maintainAspectRatio = () => map.style.height = ASPECT_RATIO * vw  + 'px'
const update = () => vw = map.getBoundingClientRect().width

window.onload = maintainAspectRatio
window.addEventListener("resize", () => { update(); maintainAspectRatio(); console.log('basd'); })

indonesia.addEventListener("click", () => {
  console.log('indo')
})
