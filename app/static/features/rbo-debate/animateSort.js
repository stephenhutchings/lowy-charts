// Global variables

var vh = window.innerHeight;
var vw = window.innerWidth;



// Setup

document.addEventListener('DOMContentLoaded', init);

function init() {
  initAnimateSort();
  console.log('Loaded');
}


// Animate sort functions

function initAnimateSort() {

  let [l,r] = document.querySelectorAll('.col-1-2');    // L-R container columns
  let sortElObj = document.querySelectorAll('.link');   // Object list of sorting elements
  let sortElArr = [...sortElObj];                       // Array list of sorting elements

  sortElObj.forEach( el => {                            // Default setup for every sortable object
    el.addEventListener('click', animateSort);
    el.classList.add('pos-abs');
  });

  spreadY(sortElArr);      // Position each article along y axis (for side-by-side view on desktop)

}

function animateSort(e) {

  let label, currentFocus;
  let parent = document.querySelector('.links');
  let inFocus = !!document.querySelectorAll('.links .fade').length; // True if any element is currently in focus
  let targets = document.querySelectorAll('.link, .links h3, .links > p'); // Elements targeted  for fading

  if (!inFocus) {
    this.querySelector('.hide').classList.add('show');
    this.querySelector('h2 a').classList.add('txt-red');

    targets.forEach( el => {
      el === this ? "" : el.classList.add('fade');
    });
  }
  else {
    parent.querySelector('.show').classList.remove('show');
    parent.querySelector('h2 a.txt-red').classList.remove('txt-red');

    targets.forEach( el => {
      el.classList.remove('fade');
    });
  }

}


// Helpers

function spreadY(a) {

  let i = y = 0;
  let n = a.length/2;
  let parent = document.querySelector('.links');

  for (i; i < n; i++) {
    a[i].style.top = a[i+n].style.top = y + 'px';
    y += Math.max(a[i].offsetHeight, a[i+n].offsetHeight);
  }

  parent.style.height = document.body.scrollHeight - parent.offsetTop + "px";

}
