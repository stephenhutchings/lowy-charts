class stickyNav {

  constructor() {
    this.currentYear = 2008;
    this.tabContainerHeight = 65;
    this.offset = 65;
    this.counts = this.loadCounts();
    this.count = this.counts['2008'];
    this.setNavLinks();
    this.positionSticky();
    this.updateCounter(2008);
    let self = this;
    $('.nav-btn').click((e) => {self.btnClick($(this), e); });
    $(window).scroll(() => { this.onScroll(); });
  }
  getZoomFactor() {
    // This is a helper function for IE7 scroll support
    var factor = 1;
    if (document.body.getBoundingClientRect) {
            // rect is only in physical pixel size in IE before version 8
        var rect = document.body.getBoundingClientRect ();
        var physicalW = rect.right - rect.left;
        var logicalW = document.body.offsetWidth;

            // the zoom level is always an integer percent value
        factor = Math.round ((physicalW / logicalW) * 100) / 100;
    }
    return factor;
}
  scrollToYear(year) {
    let y = this.getYearY(year) - this.offset;
    $('html, body').animate({scrollTop: y}, 500);
  }
  setNavLinks() {
  for(let i = 2008; i<2020; i++) {
    i == 2014 ?
      document.querySelector(`#nav--${i}`).addEventListener('click', () => this.scrollToYear(i+1)) :
      document.querySelector(`#nav--${i}`).addEventListener('click', () => this.scrollToYear(i));
  }
}
  loadCounts() {
    let counts = {
      2008: 0,
      2009: 2,
      2010: 15,
      2011: 38,
      2012: 9,
      2013: 1,
      2014: 5,
      2015: 8,
      2016: 29,
      2017: 155,
      2018: 149,
      2019: 17
    };
    return counts;
  }
  updateCounter(year, delta) {
    delta > 0 ? this.count += this.counts[year] : this.count -= this.counts[this.currentYear];
    let startHTML = "<div id='#counter'><span class='counter-num ib'>";
    let endHTML = "</span><span class='ib counter-label'>Total<br/>Mentions</span></div>";
    $('#counter').html(startHTML + this.count + endHTML);
  }
  updateActive(year) {
    let navLinks = $('.nav-content');
    let newBtn = `${year}<img class="nav-btnimg" src="img/dropbtn.svg">`
    navLinks.find('div').removeClass('active'); // Remove any active class
    navLinks.find('div[id="nav--'+ year +'"]').addClass('active'); // Apply active class to relevant nav item
    $('.nav-btn')[0].innerHTML = newBtn;
    // Update line graph and counter
    let delta = year - this.currentYear;
    if (delta) {
      this.updateCounter(year, delta);
      this.currentYear = year;
    }
}
  checkAnchors() {
    let self = this;
    let anchors = $('.anchor');
    let vh = window.innerHeight;
    let hCurrent = $(window).scrollTop();
    anchors.each( function () {
      let h = $(this).offset().top;
      // If date anchor is in top half of viewport
      if (hCurrent + vh/2 > h && hCurrent < h) {
        let year = $(this).attr('id');
        self.updateActive(year);
      }
      // If date anchor is in bottom half of viewport
      // This is to support upscrolling
      else if (hCurrent + vh > h && hCurrent + vh/2 < h) {
        let year = $(this).attr('id');
        year == 2008 ? "" : year == 2015 ? self.updateActive(year-2) : self.updateActive(year-1);
      }
    });
  }
  btnClick(button, e) {
    let dropdown = $('.nav-content');
    let display = dropdown.css('display');

    display == "block" ?
      dropdown.css('display','none') :
      dropdown.css('display','block')

    e.stopPropagation(); // stop event bubbling to document scope
  }
  getYearY(year) {
    return document.getElementById(year).offsetTop * this.getZoomFactor();
  }
  positionSticky() {
    let y = this.getYearY(2008) - this.offset;
    let current = $(window).scrollTop();
    if (y < current) {
      $('.stickyheader').css('position', 'fixed');
      $('.stickyheader').css('top', 0);
    }
    else {
      $('.stickyheader').css('position', 'absolute');
      $('.stickyheader').css('top', y);
    }
  }
  onScroll() {
    let vh = $(window).height();
    let current = $(window).scrollTop();
    let timelineTop = this.getYearY(2008) - this.offset;
    if (timelineTop < current + vh) {
      this.checkAnchors();
      this.positionSticky();
    }
  }



}
new stickyNav();

// onClick event listener
$(document).click(function(e) {
  $(e.target).is('.nav-dropitem') ? "" : $('.nav-content').css('display','none')
});
