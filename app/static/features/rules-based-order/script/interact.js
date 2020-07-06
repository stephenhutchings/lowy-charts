

function scrollThis(p, c, o) {
  $(p).animate({scrollTop: $(c)[0].offsetTop + o}, 400);
}

// on PM click
function togglePM(i, scroll) {
  let pms = ["rudd", "gillard", "abbott", "turnbull", "morrison"];
  let pm = pms[i];

  // Nav menu
  $('.tiles').addClass('nav-tiles');
  $('.tiles').children('.active').removeClass('active');
  $('.tiles').children(`.tile-${i}`).addClass('active');

  // Timeline content
  $('.show').removeClass('show');
  $(`.wrap.${pm}`).addClass('show');

  scroll ? scrollThis('html,body',`.wrap.${pm}`, -150) : "";
  positionAnnotations();
}

// TOGGLE PM-TILE HEADER
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

// TOGGLE FIXED FOOTER
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

  collapsed = !collapsed;
  let pv = 48;
  let th = $('.intro-txt').outerHeight(true) + 5*pv;
  let h = collapsed ? 0.9*vh : th;
  let html = collapsed ? '&bull; &bull; &bull;' : '<span class="txt-ml icon icon-upload"><br></span><span class="txt-s">Show less</span>';

  $('.intro-wrap').animate({'max-height': h}, 400,"");

  // TOGGLE READ-MORE BUTTON
  setTimeout(() => {
    $('.reveal')
      .html(html)
      .css('padding-top', collapsed ? '85px' : '0' );
  }, 100);

  // TOGGLE SKIP TO TIMELINE FOOTER
  toggleFooter(!collapsed);
  $('.intro-footer')
    .toggleClass('txt-xs')
    .css('min-height', collapsed ? '10vh' : '3.5em');

  collapsed ? scrollThis('html,body', '.tile-page',103) : "";

  positionAnnotations();
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
  togglePM(i, true);
}
