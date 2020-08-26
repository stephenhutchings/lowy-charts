let gdp = [
  {
    "title": "Years",
    "values": [
      1989,
      1990,
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
      461066000000,
      398623000000,
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
      5641600000000,
      5963130000000,
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

let scrollPosition, usData, cnData, yrData;
let index = 0, nYears = 31, threshold = 100*29.99/nYears;
let guide = document.querySelector('#guide');
let tooltip = document.querySelector('#tooltip');
let yrDataEl = tooltip.querySelector('.tt-year');
let usDataEl = tooltip.querySelector('.usa span');
let cnDataEl = tooltip.querySelector('.chn span');
let scrollWindow = document.querySelector('.scroll');
let graphWindow = document.querySelector('.sparkline');
let timelineHeight = document.querySelector('.timeline-wrap');
let heightOffset = timelineHeight.offsetHeight - scrollWindow.offsetHeight;

scrollWindow.addEventListener('scroll', onscroll);
graphWindow.addEventListener('mousemove', onmouse);

function onscroll() {
  scrollPosition = 100*(scrollWindow.scrollTop / heightOffset);
  scrollPosition < threshold ? "" : scrollPosition = threshold;
  guideX(scrollPosition);
}

function onmouse(e) {
  mousePosition = 100*(e.clientX - graphWindow.offsetLeft) / graphWindow.offsetWidth;
  mousePosition < threshold ? "" : mousePosition = threshold;
  mousePosition > 0 ? "" : mousePosition = 0;
  guideX(mousePosition);
}

function guideX(x) {

  index = Math.floor(nYears*x/100);

  yrData = gdp[0].values[index];
  cnData = gdp[1].values[index];
  usData = gdp[2].values[index];

  guide.setAttribute('x1', x + "%");
  guide.setAttribute('x2', x + "%");

  yrDataEl.innerHTML = yrData;
  usDataEl.innerHTML = (usData/1000000000000).toFixed(2);
  cnDataEl.innerHTML = (cnData/1000000000000).toFixed(2);

  tooltip.style.left = x < 85 ? x + "%" : `calc(${x}% - ${tooltip.offsetWidth}px)`;
  tooltip.style.top =  x < 70 ?  0 :  `calc(100% - ${tooltip.offsetHeight}px)`;
}
