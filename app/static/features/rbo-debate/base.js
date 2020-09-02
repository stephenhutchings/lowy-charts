// Global variables

var vh = window.innerHeight;
var vw = window.innerWidth;

var breakpoint = 768;
var isFocused = false;


// Setup

window.addEventListener('resize', resize);
document.addEventListener('DOMContentLoaded', init);
document.addEventListener('click', e => isFocused ? unfocus(e, this) : "" );

function init() {
  initAnimateSort();
}

function resize() {
  vw = window.innerWidth;
  vh = window.innerHeight;
  spreadY([...document.querySelectorAll('.list-item')]);
}


// DOM Manipulation

function readmore() {
  const reveal = document.querySelector('#read-more');
  const btns = document.querySelectorAll('.readmore-label');

  reveal.classList.toggle('lg-max-h');
  btns.forEach( b => {
    b.classList.toggle('hide');
    b.classList.toggle('no-ptr-ev');
  });
}
