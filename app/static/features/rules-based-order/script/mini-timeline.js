// FUNCTION DEFINITIONS FOR MINI HISTORY TIMELINES

// Set historyTimeline horizontal widths
function setHistoryTimelines() {
  // Show one node for screens < 900px. Two for > 1100px
  let screenFactor = $(window).width() < 900 ? 2 : 1;
  $('.history-timeline').each( function(i) {
    $(this).css('width', "100%");
  });

  $('.x-scroller').each( (i, el) => showHideHistoryBtns(el) );
}


// x-scroll for history box
function scrollHistory(btn, fw) {
  // fw indicates fw or back button
  let el = fw ? $(btn).next().next() : $(btn).next();
  x = fw ? el.scrollLeft() + el.outerWidth() : el.scrollLeft() - el.outerWidth();
  el.animate({scrollLeft: x}, 200);
}


// Set side-scroll buttons for historyTimelines
function showHideHistoryBtns(el) {

  let viewWidth = $(el).outerWidth();
  let endLeft = $(el).children('.history-timeline').outerWidth() - viewWidth;
  let mobile = $(window).width() < 600;

  let btnBack = $(el).prev();
  let btnFwd = $(el).prev().prev();
  let btnBackSvg = btnBack.children('svg');
  let btnFwdSvg = btnFwd.children('svg');

  if (mobile) {
    $(el).scrollLeft() < viewWidth/2 ? btnBackSvg.addClass('disabled') : btnBackSvg.removeClass('disabled'); // if at start, hide back btn
    $(el).scrollLeft() > endLeft - viewWidth/2 ? btnFwdSvg.addClass('disabled') : btnFwdSvg.removeClass('disabled'); // if at end, hide fwd btn
  }
  else {
    $(el).scrollLeft() == 0 ? (btnBack.addClass('disabled') && btnBackSvg.addClass('disabled')) : (btnBack.removeClass('disabled') && btnBackSvg.removeClass('disabled'));
    $(el).scrollLeft() >= endLeft - 5 ? (btnFwd.addClass('disabled') && btnFwdSvg.addClass('disabled')) : (btnFwd.removeClass('disabled') && btnFwdSvg.removeClass('disabled'));
  }
}
