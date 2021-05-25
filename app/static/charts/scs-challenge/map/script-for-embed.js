const ASPECT_SM  = 1000 / 780
const ASPECT_LG  = 1000 / 930
const BREAKPOINT = 800

var frame = document.querySelector('#map-frame')

const update = function(){
let w = frame.getBoundingClientRect().width;
let aspect = w < BREAKPOINT ? ASPECT_SM : ASPECT_LG;
frame.style.height = aspect * w + 'px';
}

window.onload = update
window.addEventListener("resize", update)
