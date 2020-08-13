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

  let label, map, el, t, h;
  let parent = document.querySelector('.links');
  let inFocus = !!document.querySelectorAll('.links .fade').length;       // True if any element is currently in focus
  let faders = document.querySelectorAll('.link, .links h3, .links > p'); // Elements targeted  for fading
  let sorters = document.querySelectorAll('.link');                       // Elements targeted  for sorting

  if (!inFocus) {
    map = JSON.parse(this.dataset.map);
    t = this.offsetTop;
    h = this.offsetHeight-20;
    this.querySelector('.hide').classList.add('show');
    this.querySelector('h2 a').classList.add('txt-red');
    this.querySelector('h2 a').classList.remove('no-ptr');

    faders.forEach( (el, i) => el === this ? "" : el.classList.add('fade') );

    for (i=0; i < map.length; i++ ) {
      el = sorters[map[i]-1];
      el.classList.remove('fade');
      el.style.top = t + (1 + 2*i - map.length)*(h/2) + "px";
    }
  }
  else {
    let sortElArr = [...document.querySelectorAll('.link')];   // Object list of sorting elements
    parent.querySelector('.show').classList.remove('show');
    parent.querySelector('h2 a:not(.no-ptr)').classList.add('no-ptr');
    parent.querySelector('h2 a.txt-red').classList.remove('txt-red');

    faders.forEach( el => el.classList.remove('fade') );

    spreadY(sortElArr);
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
