// Global variables

var vh = window.innerHeight;
var vw = window.innerWidth;

var breakpoint = 768;
var isFocused = false;
var isHeader = false;


// Setup

window.addEventListener('resize', resize);
document.addEventListener('DOMContentLoaded', init);
document.addEventListener('click', e => isFocused ? unfocus(e, this) : "" );
document.addEventListener('scroll', scroll );


function init() {
  window.scrollTop = 0;
  scroll();
  setTimeout( () => initAnimateSort(), 1000);
  setModal();
}

function resize() {
  vw = window.innerWidth;
  vh = window.innerHeight;
  spreadY([...document.querySelectorAll('.list-item')]);
}

function scroll() {
  if (window.pageYOffset && !isHeader) { isHeader = !isHeader; document.querySelector('header').style.opacity = 1 }
  else if (!window.pageYOffset && isHeader) { isHeader = !isHeader; document.querySelector('header').style.opacity = 0 }
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
