var vh = window.innerHeight;
var vw = window.innerWidth;
var hTopHeader = 50; // height of uppermost header (pixels)
var hTopVisible = false;
var headerVisible = false;
var footerFixed = false;
var collapsed = true;

window.addEventListener('DOMContentLoaded', onLoad);
window.addEventListener('resize', _.debounce(resizeCallback, 200));
window.addEventListener('scroll', scrollCheck);

// DOM load event listener
function onLoad() {
  resetWrapHeight('.tile-wrap','.tiles');
  createAnnotations();
  setHistoryTimelines();
  $('.x-scroller').each( (i, el) => showHideHistoryBtns(el) );
}

// Resize event listener
function resizeCallback() {
  vh = window.innerHeight;
  headerVisible ? "" : resetWrapHeight('.tile-wrap','.tiles');
  // setHistoryTimelines();
  // $('.x-scroller').each( (i, el) => showHideHistoryBtns(el) );
}

// onScroll event listener
function scrollCheck() {
  let c = $(window).scrollTop()+hTopHeader+10;

  // toggle top header
  let y = $('.credits')[0].offsetTop;
  if ( (!hTopVisible && c > y) || (hTopVisible && c < y) ) {
    $('.top-header').toggleClass('hidden');
    hTopVisible = !hTopVisible;
  }

  // toggle tile header
  let y0 = $('.tile-wrap')[0].offsetTop;
  let y1 = $('.tile.active').length ? $('.tile.active')[0].offsetTop : 99999;
  if (!headerVisible && c > y1) {toggleHeader(true);}
  else if (headerVisible && c < y0) {toggleHeader(false);}

  // toggle intro footer
  let fh = $('.intro-footer').outerHeight();
  let ty = $('.tile-page')[0].offsetTop;
  let y2 = ty - vh;
  if (!collapsed) {
    if (!footerFixed && c < y2 && c > fh) {toggleFooter(true);}
    else if (footerFixed && c > y2 + fh || c < fh) {toggleFooter(false);}
  }
}
