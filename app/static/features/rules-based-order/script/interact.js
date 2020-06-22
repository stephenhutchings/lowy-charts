var vh = window.innerHeight;
var hTopHeader = 50; // height of uppermost header (pixels)
var hTopVisible = false;
var headerVisible = false;
var footerFixed = false;
var collapsed = true;

// x-scroll for history box
function scrollHistory(btn, fw) {
  // fw indicates fw or back button
  let el = fw ? $(btn).next().next() : $(btn).next();
  x = fw ? el.scrollLeft() + el.outerWidth() : el.scrollLeft() - el.outerWidth();
  el.animate({scrollLeft: x}, 400);
}

// on PM click
function togglePM(i) {
  let pms = ["rudd", "gillard", "abbott", "turnbull", "morrison"];
  let pm = pms[i];
  // Nav menu
  $('.tiles').addClass('nav-tiles');
  $('.tiles').children('.active').removeClass('active');
  $('.tiles').children(`.tile-${i}`).addClass('active');
  // Timeline content
  $('.show').removeClass('show');
  $(`.wrap.${pm}`).addClass('show');

  scrollThis('html,body',`.wrap.${pm}`, -150)
}
function scrollThis(p, c, o) {
  $(p).animate({scrollTop: $(c)[0].offsetTop + o}, 400);
}
// Set historyTimeline horizontal widths
function setHistoryTimelines() {
  // Show one node for screens < 900px. Two for > 1100px
  let screenFactor = $(window).width() < 900 ? 2 : 1;
  let historyNodes = [3,2,3,3,3,2,9,4,5,3,2];
  $('.history-timeline').each( function(i) {
    let multiplier = $(this).prop('id') == 'absence-timeline' ? 50*screenFactor : 100
    $(this).css('width',multiplier*historyNodes[i] + "%");
  });
}
// Set side-scroll buttons for historyTimelines
function showHideHistoryBtns(el) {
  let viewWidth = $(el).outerWidth();
  let endLeft = $(el).children('.history-timeline').outerWidth() - viewWidth;
  let mobile = $(window).width() < 600 ? 1 : 0;

  if (mobile) {
    $(el).scrollLeft() < viewWidth/2 ? $(el).prev().css('display','none') : $(el).prev().css('display','block'); // if at start, hide back btn
    $(el).scrollLeft() > endLeft - viewWidth/2 ? $(el).prev().prev().css('display','none') : $(el).prev().prev().css('display','block'); // if at end, hide fwd btn
  }
  else {
    $(el).scrollLeft() == 0 ? $(el).prev().find('.h-btn').css('fill','#888') : $(el).prev().find('.h-btn').css('fill','#002b45');
    $(el).scrollLeft() >= endLeft - 5 ? $(el).prev().prev().find('.h-btn').css('fill','#888') : $(el).prev().prev().find('.h-btn').css('fill','#002b45');
  }}
// Final function calls
setHistoryTimelines();
$('.x-scroller').each( (i, el) => showHideHistoryBtns(el) );

// FIXED HEADER
function toggleHeader(show) {
  let tiles = $('.tiles');
  if (show) {
    tiles.css('height', '100px');
    tiles.addClass('header nav-tiles');
    headerVisible = true;
  }
  else {
    tiles.css('height', 'initial');
    tiles.removeClass('header nav-tiles');
    headerVisible = false;
  }
}

// FIXED FOOTER
function toggleFooter(show) {
  if (show) {
    $('.intro-footer').addClass('fixed-b');
    footerFixed = true;
  }
  else {
    $('.intro-footer').removeClass('fixed-b');
    footerFixed = false;
  }
}

function resetWrapHeight(p, c) {
  let h = $(c).outerHeight(true);
  $(p).css('min-height', h+'px');
}
function readMore() {
  // TOGGLE VISIBLE TEXT
  $('.intro-txt .collapse').toggleClass('hidden');

  collapsed = !collapsed;

  let pv = 48;
  let th = $('.intro-txt').outerHeight(true) + $('.intro-wrap .title').outerHeight(true) + 2*pv;
  let h = collapsed ? 0.9*vh : th;

  $('.intro-wrap').animate({'max-height': h}, 750,"");

  let html = collapsed ? '&bull; &bull; &bull;' : '<span class="txt-ml icon icon-upload"><br></span><span class="txt-s">Show less</span>';
  setTimeout(() => {
    $('.reveal').html(html);
    $('.reveal').css('padding-top', collapsed ? '85px' : '0' );
  }, 100);

  // ADJUST FOOTER
  toggleFooter(!collapsed);
  $('.intro-footer')
    .toggleClass('txt-l')
    .css('min-height', collapsed ? '10vh' : '3.5em');

  collapsed ? scrollThis('html,body', '.tile-page',53) : "";
}

function snapScroll() {
  let c = $(window).scrollTop();
  $('section').each( (i, s) => {
      Math.abs(c - s.offsetTop) < 100 ? scrollThis('html,body', 'section', 0) : "";
  });
}

function next(fwd) {
  let n = 5;
  let i;
  $('.tile').each( function(j, el) {if ( $(el).hasClass('active') ){i=j;}});
  i = fwd ? i+1 : i-1;
  i = i==n ? 0
    : i<0 ? n-1
    : i;
  togglePM(i);
}

//onload event listener
function onLoad() {
  resetWrapHeight('.tile-wrap','.tiles');
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

window.addEventListener('load', onLoad);
window.addEventListener('scroll', scrollCheck);
window.addEventListener('resize', _.debounce(resizeCallback, 200));
