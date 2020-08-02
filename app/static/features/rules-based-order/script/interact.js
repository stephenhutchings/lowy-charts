

function scrollThis(p, c, o, i) {
  i = i || 0;
  $(p).animate({scrollTop: $(c)[i].offsetTop + o}, 400);
}

function initThemeMenu(){

  const menu = document.getElementById('theme-menu');
  const headings = document.querySelector('.themes-txt').querySelectorAll('h2:not(.expert-name)');

  // FOR MOBILE: TOGGLE THEMES/TIMELINE INDEX
  menu.querySelectorAll('h2').forEach( (btn) => {
    btn.addEventListener('click', (e) => {
      links = e.target.nextElementSibling;
      h = links.style.maxHeight;
      links.style.maxHeight = (!h || h=='0px') ? '200vh' : 0;

      e.target.querySelector('span').classList.toggle('icon-right-sm');
      e.target.querySelector('span').classList.toggle('icon-down-sm');
    });
  });

  // SET MENU EVENT LISTENERS
  menu.querySelectorAll('li').forEach( (el, i) => {
    el.addEventListener('click', (e) => {
      if (i < 10) {
        y = headings[i].getBoundingClientRect().top + window.pageYOffset;
        $('html,body').animate({scrollTop: y-70}, 400);
      }
      else {
        togglePM(i-10, true);
      }
    });
  });
}

// on PM click
function togglePM(i, scroll) {
  let pms = ["rudd", "gillard", "abbott", "turnbull", "morrison"];
  let pm = pms[i];

  // Nav menu
  // $('.tiles').addClass('nav-tiles');
  // $('.tiles').children('.active').removeClass('active');
  // $('.tiles').children(`.tile-${i}`).addClass('active');

  // Timeline content
  $('.show').removeClass('show');
  $(`.wrap.${pm}`).addClass('show');

  scroll ? scrollThis('html,body',`.wrap.${pm}`, -50, 0) : "";
  positionAnnotations();
}

// TOGGLE PM-TILE HEADER //
  /*
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
  }*/

// ENABLE SIDE MENU
function enableSideMenu() {
  const menuBtn = document.querySelector('#side-menu .button');

  $('#side-menu').toggleClass('hidden');

  sideMenuVisible = !sideMenuVisible;
  sideMenuVisible ? menuBtn.parentElement.style.removeProperty('right') : "";

  toggleSideMenu(menuBtn);
  vw < 900 ? toggleSideMenu(menuBtn) : ""; // Menu collapsed for small screens by default
}

// TOGGLE SIDE MENU
function toggleSideMenu(el) {

  const p = el.parentElement;
  const c = el.firstElementChild;
  const w = p.querySelector('.menu-body').getBoundingClientRect().width + 2;
  let close = !el.classList.contains('closed');

  el.classList.toggle('closed');

  close ? p.style.right = -w + 'px' : p.style.right = 0;
  c.classList.toggle('icon-cancel');
  c.classList.toggle('icon-menu');
}

function initSideMenu() {

  const menu = document.getElementById('side-menu');
  const themeBody = document.querySelector('.themes-txt');

  menu.querySelectorAll('li').forEach( (el, i) => {
    el.addEventListener('click', (e) => {
      if (i < 10) {
        y = themeBody.querySelectorAll('h2')[i].getBoundingClientRect().top + window.pageYOffset;
        $('html,body').animate({scrollTop: y-70}, 400);
      }
      else {
        togglePM(i-10, true);
      }
    });
  });
}

// function resetWrapHeight(p, c) {
//   let h = $(c).outerHeight(true);
//   $(p).css('min-height', h+'px');
// }

function readMore() {

  collapsed = !collapsed;
  let pv = 48;
  let th = $('.intro-txt').outerHeight(true) + 5*pv;
  let h = collapsed ? 0.9*vh : th;
  let html = collapsed ? 'Continue reading ...' : '<span class="txt-ml icon icon-upload"></span><br>Show less';

  $('.intro-wrap').animate({'max-height': h}, 400,"");

  // TOGGLE READ-MORE BUTTON
  setTimeout(() => {
    $('.reveal')
      .html(html)
      .css('padding-top', collapsed ? '85px' : '0' );
  }, 100);

  // TOGGLE SKIP TO TIMELINE FOOTER
  // toggleFooter(!collapsed);
  // $('.intro-footer')
  //   .toggleClass('txt-xs')
  //   .css('min-height', collapsed ? '10vh' : '3.5em');

  collapsed ? scrollThis('html,body', '.intro-wrap',0) : "";

  positionAnnotations();
}

function next(fwd) {
  let n = 5;
  let i;
  $('.wrap').each( (j, el) => { $(el).hasClass('show') ? i=j : "" });
  i = fwd ? i+1 : i-1;
  i = i==n ? 0
    : i<0 ? n-1
    : i;
  togglePM(i, true);
}
