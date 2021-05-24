const ASPECT_RATIO = 895.5 / 954

var vw
var map = document.querySelector('#map')

const china = document.querySelectorAll('#China, [data-name=china]')
const brunei = document.querySelectorAll('#Brunei, [data-name=brunei]')
const vietnam = document.querySelectorAll('#Vietnam, [data-name=vietnam]')
const malaysia = document.querySelectorAll('#Malaysia, [data-name=malaysia]')
const indonesia = document.querySelectorAll('#Indonesia, [data-name=indonesia]')
const philippines = document.querySelectorAll('#Philippines, [data-name=philippines]')

const maintainAspectRatio = () => map.style.height = ASPECT_RATIO * vw  + 'px'
const update = () => vw = map.getBoundingClientRect().width

window.onload = maintainAspectRatio
window.addEventListener("resize", () => { update(); maintainAspectRatio(); console.log('basd'); })
