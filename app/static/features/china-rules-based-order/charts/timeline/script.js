// Globals
let wrap, headerSlot, headerSticky, timeline;

// Dimensions
let vh, headerH, stickyStart, stickyEnd;
let navH = 55, isSticky = false;

document.addEventListener('DOMContentLoaded', function() {setTimeout(init, 400)} );

function init() {
  setGlobals();
  setDimensions();
  window.addEventListener('scroll', onscroll);
  window.addEventListener('resize', setDimensions);
}

// Set global variables
function setGlobals() {

  // Elements
  wrap = document.querySelector('.embed-wrap');
  headerSlot = wrap.querySelector('.title-placeholder');
  chartTitle = wrap.querySelector('.chart-title');
  headerSticky = wrap.querySelector('.title-block');
  timeline = wrap.querySelector('.scroll');

}

// Dimensions
function setDimensions() {
  vh = window.innerHeight;
  stickyStart = wrap.offsetTop - navH;
  stickyEnd = stickyStart + wrap.offsetHeight + navH;
  headerH = headerSticky.offsetHeight;
  headerSlot.style.height = headerH + 'px';
}

function onscroll() {
  stickyStart = wrap.offsetTop - navH;
  let atStart = window.pageYOffset >= stickyStart;
  let atEnd = window.pageYOffset + vh > stickyEnd;
  let shouldSticky = atStart && !atEnd;

  (!isSticky && shouldSticky || isSticky && !shouldSticky) ? stickify(atStart) : "";

}

function stickify(atStart) {
  chartTitle.style.opacity = chartTitle.style.opacity==1 ? 0 : 1;
  chartTitle.classList.toggle('slidedown');
  headerSticky.classList.toggle('fixed');
  isSticky = !isSticky;
}
