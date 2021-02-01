

// Animate sort functions

function initAnimateSort() {

  let [l,r] = getAll('.col-1-2');          // L-R container columns
  let sortElObj = getAll('.list-item');    // Object list of sorting elements
  let sortElArr = [...sortElObj];          // Array list of sorting elements

  sortElObj.forEach( el => {                // Default setup for every sortable object
    el.addEventListener('click', e => { isFocused ? unfocus(e, el) : focus(el); e.stopPropagation(); });
    el.classList.add('absolute');
  });

  spreadY(sortElArr);      // Position each article along y axis (for side-by-side view on desktop)

}

function focus(el) {

  let i, targets, heights, hSum, tBlock, ti;
  let n = 6   // number of authors
  let t = el.offsetTop
  let h = el.offsetHeight
  let map = JSON.parse(el.dataset.map)
  let lhs = map[0] <= n ? true : false    // lhs TRUE for first 6 articles
  let listItems = getAll('.list-item')    // Elements targeted for fading/sorting
  let thead = getAll('.label')            // Argument / Response table labels
  let bracket = get('.bracket')           // Bracket to wrap around sorted els
  let bpOffset = 35                       // breakpoint offset for rhs sort positioning

  el.classList.add('focused')
  el.classList.remove('ptr')
  el.querySelector('.read-more').classList.remove('no-ptr-ev')  // Activate link on 'read article' button
  el.querySelector('.read-more').classList.add('show')       // Show 'read article' button
  el.querySelector('h2 a').classList.add('txt-red')          // Colorise article title
  el.querySelector('h2 a').classList.remove('no-ptr-ev')        // Activate link on article title

  listItems.forEach( (item, i) => item === el ? "" : item.classList.add('fade') )
  thead.forEach( (item, i) => item === el ? "" : item.classList.add('fade') )

  targets = map.map( (v,i) => listItems[v-1] );     // Get DOM elements
  heights = targets.map( (el) => el.offsetHeight ); // Get their heights
  hSum = heights.length ? heights.reduce( (sum, h) => sum + h ) : 0;     // Sum all their heights

  if (targets.length > 1) {                         // Set top of mapped elements
    tBlock = (vw > breakpoint) ? t + h/2 - hSum/2 : lhs ? t - hSum - bpOffset : t + 1.2*h + bpOffset;
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
    tBlock = (vw > breakpoint) ? t : lhs ? t - hSum - bpOffset : t + h;
    targets[0].classList.remove('fade');
    targets[0].style.top = tBlock + "px";
  }

  if (targets.length) {      // BRACKET POSITIONING

    lhs ? bracket.classList.remove('bracket-left') : bracket.classList.remove('bracket-right');
    lhs ? bracket.classList.add('bracket-right') : bracket.classList.add('bracket-left');
    bracket.style.top = (vw <= breakpoint && lhs) ? tBlock+hSum-bpOffset+"px" : tBlock + "px";
    bracket.style.height = (vw > breakpoint) ? hSum-10 + "px" : "25px";
    bracket.classList.remove('hide');

    if (map.length < n-1) {
      bracket.classList.remove('bracket-left-all');
      bracket.classList.remove('bracket-right-all');
    }
    else {
      lhs ? bracket.classList.add('bracket-right-all') : bracket.classList.remove('bracket-right-all');
      !lhs ? bracket.classList.add('bracket-left-all') : bracket.classList.remove('bracket-left-all');
      if (vw > breakpoint) {                    // WHEN RESPONDS TO ALL ARTICLES
        lhs ? bracket.classList.remove('bracket-right') : bracket.classList.remove('bracket-left');
        bracket.style.top = (vw <= breakpoint && lhs) ? tBlock+hSum-1.5*bpOffset+"px" : t - 10 + "px";
        bracket.style.height = (vw > breakpoint) ? 0 : "25px";
      }
    }
  }

  bracket.classList.remove('hide');
  isFocused = true;
}

function unfocus(e, el) {

  let focusedDiv = get('.focused');

  // Only unfocus if click was not on any active elements
  if ( !(e.target===focusedDiv || e.target.parentElement===focusedDiv || e.target.parentElement.classList.contains('target') )) {

    let list = get('.list');
    let listItems = getAll('.list-item');           // Elements targeted  for fading
    let sortElArr = [...getAll('.list-item')];      // Object list of sorting elements
    let focusedButton = focusedDiv.querySelector('.read-more');
    let focusedHeading = focusedDiv.querySelector('h2 a');
    let targets = getAll('.target');
    let thead = getAll('.label');                    // Argument / Response table labels
    let bracket = get('.bracket');                   // Bracket to wrap around sorted elmts

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
    thead.forEach( el => el.classList.remove('fade') );

    spreadY(sortElArr);

    isFocused = false;
  }
}


// Helpers

function spreadY(a) {

  let i = y = 0;
  let n = a.length;
  let itemMargin = 0;
  let listPaddingBottom = vw > breakpoint ? 225 : 175;
  let list = get('.list');
  let thead = getAll('.label')[1]; // Argument table label

  if (vw > breakpoint) {
    for (i; i < n/2; i++) {
      a[i].style.top = a[i+n/2].style.top = y + 'px';
      y += Math.max(a[i].offsetHeight, a[i+n/2].offsetHeight) + itemMargin;
    }
  }
  else {
    for (i; i < n; i++) {
      a[i].style.top = y + 'px';
      y += a[i].offsetHeight + itemMargin;
      if (i==n/2-1) { thead.style.top = `${y+35}px`; y+= 35; } // Set the argument table header position
    }
  }

  list.style.height = y + a[0].offsetHeight + listPaddingBottom + "px";  // Adjust height of list container

}

function checkBlockBounds(t, h) {
  let list = get('.list');
  let listItemsOffset = (list.querySelector('.flex').offsetTop + list.querySelector('.flex').offsetHeight) - list.offsetTop;
  let listHeight = list.offsetHeight - listItemsOffset;
  let bottomClearance = listHeight - t - h;

  t < 0 ? t = 0 : "";
  bottomClearance < 0 ? t = t + bottomClearance : "";
  return t;
}
