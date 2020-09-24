let gdp = [
  {
    "title": "Years",
    "values": [
      1991,
      1992,
      1993,
      1994,
      1995,
      1996,
      1997,
      1998,
      1999,
      2000,
      2001,
      2002,
      2003,
      2004,
      2005,
      2006,
      2007,
      2008,
      2009,
      2010,
      2011,
      2012,
      2013,
      2014,
      2015,
      2016,
      2017,
      2018
    ]
  },
  {
    "title": "China",
    "values": [
      415604000000,
      495671000000,
      623054000000,
      566471000000,
      736870000000,
      867224000000,
      965338000000,
      1032570000000,
      1097140000000,
      1214920000000,
      1344080000000,
      1477500000000,
      1671070000000,
      1966240000000,
      2308800000000,
      2774290000000,
      3571450000000,
      4604290000000,
      5121680000000,
      6066350000000,
      7522100000000,
      8570350000000,
      9635030000000,
      10534500000000,
      11226200000000,
      11221800000000,
      12062300000000,
      13368100000000
    ]
  },
  {
    "title": "USA",
    "values": [
      6158130000000,
      6520330000000,
      6858550000000,
      7287250000000,
      7639750000000,
      8073130000000,
      8577550000000,
      9062830000000,
      9630700000000,
      10252400000000,
      10581800000000,
      10936500000000,
      11458300000000,
      12213700000000,
      13036600000000,
      13814600000000,
      14451900000000,
      14712800000000,
      14448900000000,
      14992100000000,
      15542600000000,
      16197100000000,
      16784800000000,
      17527300000000,
      18224800000000,
      18715100000000,
      19519400000000,
      20580300000000
    ]
  }
];

// Globals
let wrap, headerSlot, headerSticky, footerSticky, footerPlotArea,
    timeline, guide, tooltip, yrDataEl, usDataEl, cnDataEl;

// Dimensions
let vh, headerH, footerH, stickyStart, stickyEnd;
let x, usData, cnData, yrData;
let navH = 55, isSticky = false,
    index = 0, nYears = 28,
    threshold = 100*27.99/nYears;

document.addEventListener('DOMContentLoaded', function() {setTimeout(init, 400)} );

function init() {
  setGlobals();
  setDimensions();
  window.addEventListener('scroll', onscroll);
  window.addEventListener('resize', setDimensions);
  footerPlotArea.addEventListener('mousemove', onmouse);
}

// Set global variables
function setGlobals() {

  // Elements
  wrap = document.querySelector('.embed-wrap');
  headerSlot = wrap.querySelector('.title-placeholder');
  chartTitle = wrap.querySelector('.chart-title');
  headerSticky = wrap.querySelector('.title-block');
  footerSticky = wrap.querySelector('#spark-wrap');
  footerPlotArea = wrap.querySelector('.sparkline');
  timeline = wrap.querySelector('.scroll');

  // Tooltip
  guide = wrap.querySelector('#guide');
  tooltip = wrap.querySelector('#tooltip');
  yrDataEl = tooltip.querySelector('.tt-year');
  usDataEl = tooltip.querySelector('.usa span');
  cnDataEl = tooltip.querySelector('.chn span');

}

// Dimensions
function setDimensions() {
  vh = window.innerHeight;
  stickyStart = wrap.offsetTop - navH;
  stickyEnd = stickyStart + wrap.offsetHeight + navH;
  headerH = headerSticky.offsetHeight;
  footerH = footerSticky.offsetHeight;
  headerSlot.style.height = headerH + 'px';
}

function onscroll() {
  stickyStart = wrap.offsetTop - navH;
  let atStart = window.pageYOffset >= stickyStart;
  let atEnd = window.pageYOffset + vh > stickyEnd;
  let shouldSticky = atStart && !atEnd;

  (!isSticky && shouldSticky || isSticky && !shouldSticky) ? stickify(atStart) : "";
  if (atStart) {
    x = 100 * ( (window.pageYOffset - stickyStart) / (stickyEnd - stickyStart - vh) );
    guideX(x);
  }

}

function onmouse(e) {
  let o = isSticky ? footerPlotArea.offsetLeft + footerSticky.offsetLeft : footerPlotArea.offsetLeft;
  x = 100 * (e.clientX - o) / footerPlotArea.offsetWidth;
  guideX(x, true);
}

function guideX(x, isMouse) {

  x < threshold ? "" : x = threshold;
  x > 0 ? "" : x = 0;

  if (!isMouse) {
    guide.style.transition = "transform 0.4s";
    tooltip.style.transition = "top 0.4s, left 0.4s";
    if ( x < 20 )      { yr = 1991; x=yearToX(yr); }
    else if ( x < 39 ) { yr = 1999; x=yearToX(yr); }
    else if ( x < 60 ) { yr = 2001; x=yearToX(yr); }
    else if ( x < 71 ) { yr = 2003; x=yearToX(yr); }
    else if ( x < 74 ) { yr = 2006; x=yearToX(yr); }
    else if ( x < 92 ) { yr = 2008; x=yearToX(yr); }
    else if ( x < 96 ) { yr = 2014; x=yearToX(yr); }
    else if ( x < 98 ) { yr = 2017; x=yearToX(yr); }
    else               { yr = 2018; x=yearToX(yr); }
  }
  else {
    guide.style.transition = "transform 0s";
    tooltip.style.transition = "top 0s, left 0s";
  }

  x < threshold ? "" : x = threshold;
  x > 0 ? "" : x = 0;
  index = Math.floor(nYears*x/100);

  yrData = gdp[0].values[index];
  cnData = gdp[1].values[index];
  usData = gdp[2].values[index];

  yrDataEl.innerHTML = yrData;
  usDataEl.innerHTML = (usData/1000000000000).toFixed(2);
  cnDataEl.innerHTML = (cnData/1000000000000).toFixed(2);

  guide.style.transform = 'translateX(' + x + "%)";

  tooltip.style.left = x < 64 ? x + "%" : `calc(${x}% - ${tooltip.offsetWidth}px)`;
  tooltip.style.top =  x < 64 ?  0 :  `calc(100% - ${tooltip.offsetHeight}px)`;
}

function stickify(atStart) {

  chartTitle.style.opacity = chartTitle.style.opacity==1 ? 0 : 1;
  headerSticky.classList.toggle('fixed');
  footerSticky.classList.toggle('fixed');
  footerSticky.classList.toggle('sticky-footer');

  isSticky = !isSticky;
}

function yearToX(year) {
  return (100*(year-1991)/(nYears-1)).toFixed(1);
}
