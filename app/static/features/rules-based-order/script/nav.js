class stickyNav {

  constructor() {
    this.currentYear = 2008;
    this.tabContainerHeight = 65;
    this.offset = 65;
    this.stickyVisible = false;
    this.setNavLinks();
    this.positionSticky();
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
  for(let i = 2008; i<=2020; i++) {
    i == 2014 ?
      document.querySelector(`#nav--${i}`).addEventListener('click', () => this.scrollToYear(i+1)) :
      document.querySelector(`#nav--${i}`).addEventListener('click', () => this.scrollToYear(i));
  }
}
  updateActive(year) {
    let navLinks = $('.nav-drop');
    let newBtn = `${year}<img class="nav-btnimg" src="img/dropbtn.svg">`
    navLinks.find('div').removeClass('active'); // Remove any active class
    navLinks.find('div[id="nav--'+ year +'"]').addClass('active'); // Apply active class to relevant nav item
    $('.nav-btn')[0].innerHTML = newBtn;
}
  checkAnchors() {
    let self = this;
    let anchors = $('.anchor');
    let vh = window.innerHeight;
    let hCurrent = $(window).scrollTop();
    anchors.each( function () {
      let h = $(this).offset().top;
      let id = $(this).attr('id')
      let year = id.slice(id.length - 4) // Remove 'anchor-' from id name to get year
      // If date anchor is in top half of viewport
      if (hCurrent + vh/2 > h && hCurrent < h) {
        self.updateActive(year);
      }
      // If date anchor is in bottom half of viewport
      // This is to support upscrolling
      else if (hCurrent + vh > h && hCurrent + vh/2 < h) {
        year == 2008 ? "" : year == 2015 ? self.updateActive(year-2) : self.updateActive(year-1);
      }
    });
  }
  btnClick(button, e) {
    let dropdown = $('.nav-drop');
    let display = dropdown.css('display');

    display == "block" ?
      dropdown.css('display','none') :
      dropdown.css('display','block')

    e.stopPropagation(); // stop event bubbling to document scope
  }
  getYearY(year) {
    let id = 'anchor-' + year;
    return document.getElementById(id).offsetTop * this.getZoomFactor();
  }
  positionSticky() {
    let y = this.getYearY(2008) - this.offset;
    let current = $(window).scrollTop();
    if (y < current) { // If we've scrolled beyond the start of the timeline
      if (!this.stickyVisible) {
        $('.stickyheader').css('display', 'flex');
        $('.stickyheader').css('position', 'fixed');
        $('.stickyheader').css('top', 0);
        this.stickyVisible = true;
      }
    }
    else {
      $('.stickyheader').css('display', 'none');
      $('.stickyheader').css('top', y);
      this.stickyVisible = false;
    }
  }
  onScroll() {
    let vh = $(window).height();
    let current = $(window).scrollTop();
    let timelineTop = this.getYearY(2008) - this.offset;
    this.positionSticky();
    if (timelineTop < current + vh) {
      this.checkAnchors();
    }
  }



}
new stickyNav();

// onClick event listener
$(document).click(function(e) {
  $(e.target).is('.nav-dropitem') ? "" : $('.nav-drop').css('display','none')
});
