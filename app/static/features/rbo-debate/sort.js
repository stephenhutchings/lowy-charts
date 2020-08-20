// Global variables

var vh = window.innerHeight;
var vw = window.innerWidth;

var isFocused = false;


// Setup

document.addEventListener('DOMContentLoaded', init);
document.addEventListener('click', e => isFocused ? unfocus(e, this) : "" );

function init() {
  initAnimateSort();
}

// Animate sort functions

function initAnimateSort() {

  let [l,r] = document.querySelectorAll('.col-1-2');          // L-R container columns
  let sortElObj = document.querySelectorAll('.list-item');    // Object list of sorting elements
  let sortElArr = [...sortElObj];                             // Array list of sorting elements

  sortElObj.forEach( el => {                                   // Default setup for every sortable object
    el.addEventListener('click', e => { isFocused ? unfocus(e, el) : focus(el); e.stopPropagation(); });
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
  let listItems = document.querySelectorAll('.list-item');    // Elements targeted for fading/sorting
  let bracket = document.querySelector('.bracket');           // Bracket to wrap around sorted els

  el.classList.add('focused');
  el.classList.remove('ptr');
  el.querySelector('.read-more').classList.remove('no-ptr-ev');  // Activate link on 'read article' button
  el.querySelector('.read-more').classList.add('show');       // Show 'read article' button
  el.querySelector('h2 a').classList.add('txt-red');          // Colorise article title
  el.querySelector('h2 a').classList.remove('no-ptr-ev');        // Activate link on article title

  listItems.forEach( (item, i) => item === el ? "" : item.classList.add('fade') );

  targets = map.map( (v,i) => listItems[v-1] );     // Get DOM elements
  heights = targets.map( (el) => el.offsetHeight ); // Get their heights
  hSum = heights.length ? heights.reduce( (sum, h) => sum + h ) : 0;     // Sum all their heights

  if (targets.length > 1) {                         // Set top of mapped elements
    tBlock = t + h/2 - hSum/2;
    tBlock = checkBlockBounds(tBlock, hSum);
    targets.forEach( (el, i) => {
      el.classList.add('target', 'z1');
      el.classList.remove('fade','ptr');
      el.querySelector('h2 a').classList.remove('no-ptr-ev');     // Activate link on article title
      ti = heights.reduce( (sum, h, j) => j<=i ? sum + h : sum ); // Cumulative height of items thus far
      ti -= heights[i];                                           // Minus height of this item
      el.style.top = tBlock + ti + "px";                          // Offset this from the block top
    });
  }
  else if (targets.length==1){
    tBlock = t;
    targets[0].classList.remove('fade');
    targets[0].style.top = tBlock + "px";
  }

  if (targets.length) {
    bracket.style.top = tBlock + "px";
    bracket.style.height = hSum-10 + "px";
    bracket.classList.remove('hide');
    lhs ? bracket.classList.remove('bracket-left') : bracket.classList.remove('bracket-right');
    lhs ? bracket.classList.add('bracket-right') : bracket.classList.add('bracket-left');
    map.length==6 && lhs ? bracket.classList.add('bracket-right-all') : bracket.classList.remove('bracket-right-all');
    map.length==6 && !lhs ? bracket.classList.add('bracket-left-all') : bracket.classList.remove('bracket-left-all');
  }

  isFocused = true;
}

function unfocus (e, el) {

  let focusedDiv = document.querySelector('.focused');

  // Only unfocus if click was not on any active elements
  if ( !(e.target===focusedDiv || e.target.parentElement===focusedDiv || e.target.parentElement.classList.contains('target') )) {

    let list = document.querySelector('.list');
    let listItems = document.querySelectorAll('.list-item');           // Elements targeted  for fading
    let sortElArr = [...document.querySelectorAll('.list-item')];      // Object list of sorting elements
    let focusedButton = focusedDiv.querySelector('.read-more');
    let focusedHeading = focusedDiv.querySelector('h2 a');
    let targets = document.querySelectorAll('.target');
    let bracket = document.querySelector('.bracket');                   // Bracket to wrap around sorted elmts

    targets.forEach( (el) => {
      el.classList.remove('target', 'z1');
      el.classList.add('ptr');
      el.querySelector('h2 a').classList.add('no-ptr-ev', 'ptr');
    });

    focusedDiv.classList.remove('focused');
    focusedDiv.classList.add('ptr');
    focusedHeading.classList.remove('txt-red');
    focusedHeading.classList.add('no-ptr-ev');
    focusedButton.classList.remove('show');
    focusedButton.classList.add('no-ptr-ev');

    bracket.classList.add('hide');

    listItems.forEach( el => el.classList.remove('fade') );

    spreadY(sortElArr);

    isFocused = false;
  }
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

  list.style.height=="" ? list.style.height = document.body.scrollHeight - list.offsetTop + listPaddingBottom + "px" : "";

}


function checkBlockBounds(t, h) {
  let list = document.querySelector('.list');
  let listItemsOffset = (list.querySelector('.flex').offsetTop + list.querySelector('.flex').offsetHeight) - list.offsetTop;
  let listHeight = list.offsetHeight - listItemsOffset;
  let bottomClearance = listHeight - t - h;

  t < 0 ? t = 0 : "";
  bottomClearance < 0 ? t = t + bottomClearance : "";
  return t;
}
