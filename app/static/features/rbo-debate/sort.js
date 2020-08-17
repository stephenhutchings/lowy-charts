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

  let i, targets, heights, hSum, tBlock, ti;
  let t = el.offsetTop;
  let h = el.offsetHeight;
  let map = JSON.parse(el.dataset.map);
  let lhs = map[0] < 8 ? true : false;
  let faders = document.querySelectorAll('.list-item, .list > h3, .list > p');  // Elements targeted for fading
  let sorters = document.querySelectorAll('.list-item');                        // Elements targeted for sorting
  let bracket = document.querySelector('.bracket');                             // Bracket to wrap around sorted els

  el.querySelector('.read-more').classList.remove('no-ptr');  // Activate link on 'read article' button
  el.querySelector('.read-more').classList.add('show');       // Show 'read article' button
  el.querySelector('h2 a').classList.add('txt-red');          // Colorise article title
  el.querySelector('h2 a').classList.remove('no-ptr');        // Activate link on article title

  faders.forEach( (item, i) => item === el ? "" : item.classList.add('fade') );

  targets = map.map( (v,i) => sorters[v-1] );       // Get DOM elements
  heights = targets.map( (el) => el.offsetHeight ); // Get their heights
  hSum = heights.reduce( (sum, h) => sum + h );     // Sum all their heights

  if (targets.length > 1) {                         // Set top of mapped elements
    tBlock = t + h/2 - hSum/2;
    tBlock < 0 ? tBlock = 0 : "";
    targets.forEach( (el, i) => {
      el.classList.remove('fade');
      ti = heights.reduce( (sum, h, j) => j<=i ? sum + h : sum ); // Cumulative height of items thus far
      ti -= heights[i];                                           // Minus height of this item
      el.style.top = tBlock + ti + "px";                          // Offset this from the block top
    });
  }
  else {
    tBlock = t;
    targets[0].classList.remove('fade');
    targets[0].style.top = tBlock + "px";
  }


  bracket.style.top = tBlock + "px";
  bracket.style.height = hSum-10 + "px";
  bracket.classList.remove('hide');
  lhs ? bracket.classList.remove('bracket-left') : bracket.classList.remove('bracket-right');
  lhs ? bracket.classList.add('bracket-right') : bracket.classList.add('bracket-left');

  isFocused = true;
}

function unfocus (el) {
  let list = document.querySelector('.list');
  let faders = document.querySelectorAll('.list-item, .list > h3, .list > p'); // Elements targeted  for fading
  let sortElArr = [...document.querySelectorAll('.list-item')];                // Object list of sorting elements
  let focusedHeading = list.querySelector('h2 a:not(.no-ptr)');
  let focusedButton = list.querySelector('.read-more:not(.no-ptr)');
  let bracket = document.querySelector('.bracket');                             // Bracket to wrap around sorted els

  focusedHeading.classList.remove('txt-red');
  focusedHeading.classList.add('no-ptr');
  focusedButton.classList.remove('show');
  focusedButton.classList.add('no-ptr');

  bracket.classList.add('hide');

  faders.forEach( el => el.classList.remove('fade') );

  spreadY(sortElArr);

  isFocused = false;
}


// Helpers

function spreadY(a) {

  let i = y = 0;
  let n = a.length/2;
  let itemMargin = 0;
  let listPaddingBottom = 70;
  let list = document.querySelector('.list');

  for (i; i < n; i++) {
    a[i].style.top = a[i+n].style.top = y + 'px';
    y += Math.max(a[i].offsetHeight, a[i+n].offsetHeight) + itemMargin;
  }

  list.style.height = document.body.scrollHeight - list.offsetTop + listPaddingBottom + "px";

}
