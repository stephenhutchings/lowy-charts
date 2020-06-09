var rtime;
var timeout = false;
var delta = 200;
var headerVisible = false;

// Resize debounce
$(window).resize(function() {
  rtime = new Date();
  if (timeout === false) {
      timeout = true;
      setTimeout(resizeend, delta);
  }
});
// Resize callback
function resizeend() {
  if (new Date() - rtime < delta) {
      setTimeout(resizeend, delta);
  } else {
      timeout = false;
      setHistoryTimelines();
      $('.x-scroller').each( (i, el) => showHideHistoryBtns(el) );
  }
}
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
  $('.tiles').children('.active').removeClass('active');
  $('.tiles').children(`.tile-${i}`).addClass('active');
  // Timeline content
  $('.show').removeClass('show');
  $(`.card.wrap.${pm}`).addClass('show');
  scrollThis('html,body',`.card.wrap.${pm}`, -100)
}
function scrollThis(p, c, o) {
  $(p).animate({scrollTop: $(c)[0].offsetTop + o}, 500);
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
    tiles.addClass('header nav-tiles fixed');
    headerVisible = true;
  }
  else {
    tiles.css('height', '120px');
    tiles.removeClass('header nav-tiles fixed');
    headerVisible = false;
  }
}

// Scroll event listener
function headerCheck() {
  let c = $(window).scrollTop();
  let tiles = $('.tile-wrap')[0].offsetTop;
  if (!headerVisible && c > tiles) {toggleHeader(true);}
  else if (headerVisible && c < tiles) {toggleHeader(false);}
}
window.addEventListener('scroll', headerCheck);