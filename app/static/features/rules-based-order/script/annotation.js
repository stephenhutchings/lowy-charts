const sources = [
  {
    "id": "1",
    "ref": "Address by former FM, Gareth Evans, March 1990"
  },
  {
    "id": "2",
    "ref": "2016 Defence White Paper"
  },
  {
    "id": "3",
    "ref": "Prime Minister Scott Morrison’s address to the United Nations General Assembly, September 2019"
  },
  {
    "id": "4",
    "ref": "Foreign Minister, Marise Payne’s address to the ANU National Security College, June 2020"
  },
  {
    "id": "5",
    "ref": "Prime Minister Julia Gillard’s speech to the African Union Permanent Representatives, March 2011"
  },
  {
    "id": "6",
    "ref": "Foreign Minister Julie Bishop’s comments on North Korean ballistic missile tests, July 2017"
  },
  {
    "id": "7",
    "ref": "Prime Minister Tony Abbott’s address to the United Nations General Assembly in New York, September 2014"
  },
  {
    "id": "8",
    "ref": "Prime Minister Malcolm Turnbull’s speech at the launch of the Foreign Policy White Paper, November 2017"
  },
  {
    "id": "9",
    "ref": "Prime Minister Malcolm Turnbull’s keynote address at the Shangri-La Dialogue, June 2017"
  },
  {
    "id": "10",
    "ref": "Joint press conference by Prime Minister Turnbull and Foreign Minister Payne on South China Sea arbitration decision, July 2016"
  },
  {
    "id": "11",
    "ref": "2017 Foreign Policy White Paper"
  },
  {
    "id": "12",
    "ref": "Prime Minister Malcolm Turnbull’s remarks to US Chamber of Commerce, January 2016"
  },
  {
    "id": "13",
    "ref": "Defence Minister Linda Reynolds’ address to the Hudson Institute, Washington DC, November 2019"
  },
  {
    "id": "14",
    "ref": "2013 Defence White Paper"
  },
  {
    "id": "15",
    "ref": "Prime Minister Kevin Rudd’s address to The Brookings Institution, Washington DC, March 2008"
  },
  {
    "id": "16",
    "ref": "Prime Minister Tony Abbott’s address to Parliamentary dinner for Xi Jinping, November 2014"
  },
  {
    "id": "17",
    "ref": "Prime Minister Malcolm Turnbull’s speech at lunch in honour of Premier Li, March 2017"
  },
  {
    "id": "18",
    "ref": "2012 Australia in the Asian Century White Paper"
  },
  {
    "id": "19",
    "ref": "Prime Minister Scott Morrison’s address to the Sydney Institute, December 2018"
  },
  {
    "id": "20",
    "ref": "2009 Defence White Paper"
  },
  {
    "id": "21",
    "ref": "2020 Defence Strategic Update"
  },
  {
    "id": "22",
    "ref": "Address by Prime Minister Morrison to launch the 2020 Defence Strategic Update"
  },
  {
    "id": "23",
    "ref": "Prime Minister Malcolm Turnbull’s 2016 Lowy Lecture"
  },
  {
    "id": "24",
    "ref": "2013 PM&C Strategy Document 'Strong and Secure: A Strategy for Australia’s National Security'"
  }
];

var annotations = document.querySelectorAll('cite');

// Creates nested divs for each annotation link in introduction
// Sets background image class for all commentator annotations
function createAnnotations() {

  annotations.forEach( (el, i) => {
    let isComment = el.classList.length;
    let attr = isComment ? el.getAttribute('tooltip') : el.getAttribute('ref');
    let data = isComment ? attr : sources.find(src => src.id == attr ).ref;

    el.appendChild(document.createElement("span")).innerHTML = data;

    isComment ? el.classList.add('bg-ccnr') : el.innerHTML += '^';

    el.addEventListener('mouseover', hoverAnnotation);
    el.addEventListener('mouseleave', unhoverAnnotation);
    el.addEventListener('touchstart', hoverAnnotation);
    el.addEventListener('touchend', unhoverAnnotation);
  });

}

// Adjusts position of tooltip to keep within viewport
function positionAnnotations() {

  annotations.forEach( (el, i) => {
    textbox = el.querySelector('span');
    if ( !el.classList.contains('no-reposition') ) {
      textbox.style.display = 'inline';
      l = textbox.getBoundingClientRect().left;
      r = textbox.getBoundingClientRect().right;
      dr = r + 30 - vw;
      initial = (l-r)/2 + 14;

      l < 0 ? textbox.style.left = (initial-l)+'px' : "";
      dr > 0 ? textbox.style.left = (initial - dr)+'px' : "";

      textbox.style.removeProperty('display');
    }
    else { // For the comments in a history box
      eventNode = el.parentNode.parentNode;
      w = eventNode.getBoundingClientRect().width;
      textbox.style.minWidth = w+'px';
      textbox.style.left = -(w/2)+10+'px';
    }
  });
}

// Event listener for mouse-over annotations
function hoverAnnotation(e) {

  let l0, rect, t, l, r, dr;
  let textbox = e.target.firstElementChild; // Get bubble box
  textbox.style.display = 'block'; // Show it
  l0 = (l-r)/2 + 14
  rect = textbox.getBoundingClientRect(); // Get its top coordinate
  t = rect.top;
  r = rect.right + 30 - vw;

  t < 0 ? ( (textbox.style.top = '110%') && (textbox.style.bottom = 'auto') ) : ""; // If hidden, show it below the avatar
  r > 0 ? ( textbox.style.left = (l0-r) + 'px' ) : ""; // If cutoff on right
}

// Event listener for hiding annotations
function unhoverAnnotation(e) {

  let textbox = e.target.firstElementChild;
  textbox.style.display = 'none';
  textbox.style.removeProperty('bottom');
  textbox.style.removeProperty('top');

}
