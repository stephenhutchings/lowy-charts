const annotations = document.querySelectorAll('cite');

// Creates nested divs for each annotation link in introduction
function createAnnotations() {
  annotations.forEach( (el, i) => {
    s = el.appendChild(document.createElement("span"));
    data = el.getAttribute('tooltip');
    s.innerHTML = data;
  });
}

// Adjusts position of tooltip to keep within viewport
function positionAnnotations() {

  annotations.forEach( (el, i) => {
    textbox = el.querySelector('span');
    textbox.style.display = 'inline';
    l = textbox.getBoundingClientRect().left;
    r = textbox.getBoundingClientRect().right;
    dr = vw - r;
    offset = (r-l)/2;
    console.log(l, r);

    l < 0 ? textbox.style.left = -(l+offset)+'px' : "";
    dr < 0 ? textbox.style.left = (dr-offset)+'px' : "";

    //textbox.style.removeProperty('display');
  });
}
