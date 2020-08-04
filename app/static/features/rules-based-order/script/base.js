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
  createAnnotations();
  initContentsMenu();
  initSideMenu();
  setHistoryTimelines();
  togglePM(0, false);
}

// Resize event listener
function resizeCallback() {
  vh = window.innerHeight;
  vw = window.innerWidth;
  setHistoryTimelines();
  positionAnnotations();
  vw < 750 ? initContentsMenuForMobile() : initContentsMenuForMobile(true);
}

// onScroll event listener
function scrollCheck() {
  let c = $(window).scrollTop()+hTopHeader+10;

  // toggle top header
  let y = $('.intro-wrap')[0].offsetTop;
  if ( (!hTopVisible && c > y) || (hTopVisible && c < y) ) {
    $('.top-header').toggleClass('hidden');
    hTopVisible = !hTopVisible;
  }

  // toggle side menu
  let y2 = $('#theme-menu')[0].offsetTop + vh/2.5;
  (!sideMenuVisible && c > y2 ) || (sideMenuVisible && c < y2 ) ? enableSideMenu() : "";

}
