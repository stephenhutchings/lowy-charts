var vh = window.innerHeight;
var vw = window.innerWidth;
var hTopHeader = 50; // height of uppermost header (pixels)
var hTopVisible = false;
var headerVisible = false;
var sideMenuVisible = false;
var collapsed = true;

window.addEventListener('DOMContentLoaded', onLoad);
window.addEventListener('resize', _.debounce(resizeCallback, 200));
window.addEventListener('scroll', scrollCheck);

// DOM load event listener
function onLoad() {
  // resetWrapHeight('.tile-wrap','.tiles');
  createAnnotations();
  initThemeMenu();
  initSideMenu();
  setHistoryTimelines();
  togglePM(0, false);
}

// Resize event listener
function resizeCallback() {
  vh = window.innerHeight;
  vw = window.innerWidth;
  headerVisible ? "" : resetWrapHeight('.tile-wrap','.tiles');
  setHistoryTimelines();
  positionAnnotations();
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
  // let y0 = $('.tile-wrap')[0].offsetTop;
  // let y1 = $('.tile.active').length ? $('.tile.active')[0].offsetTop : 99999;
  // if (!headerVisible && c > y1) {toggleHeader(true);}
  // else if (headerVisible && c < y0) {toggleHeader(false);}

  // toggle intro footer
  let sideMenu = $('.side-menu').outerHeight();
  let y2 = $('#theme-menu')[0].offsetTop + vh/2.5;
  (!sideMenuVisible && c > y2 ) || (sideMenuVisible && c < y2 ) ? enableSideMenu() : "";
}
