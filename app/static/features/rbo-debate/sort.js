// Global variables

var vh = window.innerHeight;
var vw = window.innerWidth;

var isFocused = false;


// Setup

document.addEventListener('DOMContentLoaded', init);
document.addEventListener('click', e => isFocused ? unfocus() : "" );

function init() {
  initAnimateSort();
}


// Animate sort functions

function initAnimateSort() {

  let [l,r] = document.querySelectorAll('.col-1-2');          // L-R container columns
  let sortElObj = document.querySelectorAll('.list-item');    // Object list of sorting elements
  let sortElArr = [...sortElObj];                             // Array list of sorting elements

  sortElObj.forEach( el => {                                   // Default setup for every sortable object
    el.addEventListener('click', e => { isFocused ? unfocus(el) : focus(el); e.stopPropagation(); });
    el.classList.add('pos-abs');
  });

  spreadY(sortElArr);      // Position each article along y axis (for side-by-side view on desktop)

}

function focus(el) {

  let i, targets;
  let t = el.offsetTop;
  let h = el.offsetHeight;
  let map = JSON.parse(el.dataset.map);
  let faders = document.querySelectorAll('.list-item, .list > h3, .list > p');  // Elements targeted for fading
  let sorters = document.querySelectorAll('.list-item');                        // Elements targeted for sorting

  el.querySelector('.read-more').classList.remove('no-ptr');  // Activate link on 'read article' button
  el.querySelector('.read-more').classList.add('show');       // Show 'read article' button
  el.querySelector('h2 a').classList.add('txt-red');          // Colorise article title
  el.querySelector('h2 a').classList.remove('no-ptr');        // Activate link on article title

  faders.forEach( (item, i) => item === el ? "" : item.classList.add('fade') );

  for (i=0; i < map.length; i++ ) {
    targets = sorters[map[i]-1];
    targets.classList.remove('fade');
    targets.style.top = t + (1 + 2*i - map.length)*(h/2) + "px";
  }

  isFocused = true;
}

function unfocus (el) {
  let list = document.querySelector('.list');
  let faders = document.querySelectorAll('.list-item, .list > h3, .list > p'); // Elements targeted  for fading
  let sortElArr = [...document.querySelectorAll('.list-item')];                // Object list of sorting elements
  let focusedHeading = list.querySelector('h2 a:not(.no-ptr)');
  let focusedButton = list.querySelector('.read-more:not(.no-ptr)');

  focusedHeading.classList.remove('txt-red');
  focusedHeading.classList.add('no-ptr');
  focusedButton.classList.remove('show');
  focusedButton.classList.add('no-ptr');

  faders.forEach( el => el.classList.remove('fade') );

  spreadY(sortElArr);

  isFocused = false;
}


// Helpers

function spreadY(a) {

  let i = y = 0;
  let n = a.length/2;
  let itemMargin = 20;
  let listMargin = 70
  let list = document.querySelector('.list');

  for (i; i < n; i++) {
    a[i].style.top = a[i+n].style.top = y + 'px';
    y += Math.max(a[i].offsetHeight, a[i+n].offsetHeight) + itemMargin;
  }

  list.style.height = document.body.scrollHeight - list.offsetTop + listMargin + "px";

}
