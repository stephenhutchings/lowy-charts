const data = [
  {
    "province": 0,
    "name": "Lifou",
    "id": 0,
    "for_independence": 0.8,
    "kanak": 0.91
  },
  {
    "province": 0,
    "name": "Mar\u00e9",
    "id": 1,
    "for_independence": 0.85,
    "kanak": 0.97
  },
  {
    "province": 0,
    "name": "Ouv\u00e9a",
    "id": 2,
    "for_independence": 0.84,
    "kanak": 0.92
  },
  {
    "province": 1,
    "name": "B\u00e9lep",
    "id": 3,
    "for_independence": 0.94,
    "kanak": 0.95
  },
  {
    "province": 1,
    "name": "Canala",
    "id": 4,
    "for_independence": 0.94,
    "kanak": 0.96
  },
  {
    "province": 1,
    "name": "Hiengh\u00e8ne",
    "id": 5,
    "for_independence": 0.95,
    "kanak": 0.93
  },
  {
    "province": 1,
    "name": "Houa&iuml;lou",
    "id": 6,
    "for_independence": 0.84,
    "kanak": 0.85
  },
  {
    "province": 1,
    "name": "Kaala-Gomen",
    "id": 7,
    "for_independence": 0.75,
    "kanak": 0.7
  },
  {
    "province": 1,
    "name": "Kon\u00e9",
    "id": 8,
    "for_independence": 0.64,
    "kanak": 0.53
  },
  {
    "province": 1,
    "name": "Kouaoua",
    "id": 9,
    "for_independence": 0.74,
    "kanak": 0.86
  },
  {
    "province": 1,
    "name": "Koumac",
    "id": 10,
    "for_independence": 0.36,
    "kanak": 0.33
  },
  {
    "province": 1,
    "name": "Ou\u00e9goa",
    "id": 11,
    "for_independence": 0.7,
    "kanak": 0.58
  },
  {
    "province": 1,
    "name": "Poindimi\u00e9",
    "id": 12,
    "for_independence": 0.79,
    "kanak": 0.74
  },
  {
    "province": 1,
    "name": "Pon\u00e9rihouen",
    "id": 13,
    "for_independence": 0.86,
    "kanak": 0.88
  },
  {
    "province": 1,
    "name": "Pou\u00e9bo",
    "id": 14,
    "for_independence": 0.94,
    "kanak": 0.95
  },
  {
    "province": 1,
    "name": "Pouembout",
    "id": 15,
    "for_independence": 0.47,
    "kanak": 0.26
  },
  {
    "province": 1,
    "name": "Poum",
    "id": 16,
    "for_independence": 0.84,
    "kanak": 0.83
  },
  {
    "province": 1,
    "name": "Poya Nord",
    "id": 17,
    "for_independence": 0.64,
    "kanak": 0.59
  },
  {
    "province": 1,
    "name": "Touho",
    "id": 18,
    "for_independence": 0.83,
    "kanak": 0.75
  },
  {
    "province": 1,
    "name": "Voh",
    "id": 19,
    "for_independence": 0.69,
    "kanak": 0.51
  },
  {
    "province": 2,
    "name": "Boulouparis",
    "id": 20,
    "for_independence": 0.3,
    "kanak": 0.31
  },
  {
    "province": 2,
    "name": "Bourail",
    "id": 21,
    "for_independence": 0.31,
    "kanak": 0.32
  },
  {
    "province": 2,
    "name": "Dumb\u00e9a",
    "id": 22,
    "for_independence": 0.22,
    "kanak": 0.32
  },
  {
    "province": 2,
    "name": "Farino",
    "id": 23,
    "for_independence": 0.09,
    "kanak": 0.05
  },
  {
    "province": 2,
    "name": "l'\u00cele des Pins",
    "id": 24,
    "for_independence": 0.67,
    "kanak": 0.86
  },
  {
    "province": 2,
    "name": "La Foa",
    "id": 25,
    "for_independence": 0.3,
    "kanak": 0.23
  },
  {
    "province": 2,
    "name": "Moindou",
    "id": 26,
    "for_independence": 0.44,
    "kanak": 0.46
  },
  {
    "province": 2,
    "name": "Mont-Dore",
    "id": 27,
    "for_independence": 0.26,
    "kanak": 0.22
  },
  {
    "province": 2,
    "name": "Noum\u00e9a",
    "id": 28,
    "for_independence": 0.19,
    "kanak": 0.25
  },
  {
    "province": 2,
    "name": "Pa\u00efta",
    "id": 29,
    "for_independence": 0.26,
    "kanak": 0.19
  },
  {
    "province": 2,
    "name": "Poya Sud",
    "id": 30,
    "for_independence": 0.02,
    "kanak": 0.05
  },
  {
    "province": 2,
    "name": "Sarram\u00e9a",
    "id": 31,
    "for_independence": 0.73,
    "kanak": 0.72
  },
  {
    "province": 2,
    "name": "Thio",
    "id": 32,
    "for_independence": 0.83,
    "kanak": 0.78
  },
  {
    "province": 2,
    "name": "Yat\u00e9",
    "id": 33,
    "for_independence": 0.88,
    "kanak": 0.96
  }
]


let vw = window.innerWidth;
/* let l = wrap.getBoundingClientRect().left;
let w = wrap.getBoundingClientRect().width; */

let commune;
let polygons = document.querySelectorAll('#map path');
let wrap = document.querySelector('.wrapper');
let labels = document.querySelectorAll('#labels g');

const maintainAspectRatio = function() { vw < 800 ? wrap.style.height = 0.75*vw  + 'px' : "" };

window.onload = maintainAspectRatio;
window.addEventListener("resize", () => { vw = window.innerWidth; maintainAspectRatio(); });

document.addEventListener("DOMContentLoaded", initialise);

function initialise() {
  let radios = document.querySelectorAll('input[type=radio]');
  radios.forEach( (r,i) => r.addEventListener('change', () => colorize(i) ) );
  polygons.forEach( (p,i) => addTooltip(p, i) );
  colorize(0);
}

function addTooltip(el,i) {
  el.addEventListener('mouseover', () => {

    let tooltip = document.querySelector('.tooltip');
    let centroid = document.querySelectorAll('circle')[i];
    let commune = data.filter( c => c.id == el.dataset.id )[0];
    let box = el.getBoundingClientRect();

    tooltip.innerHTML = `<b>${commune.name}</b><br>${commune.kanak}% Kanak population<br>${commune.for_independence}% vote for independence`;
    tooltip.style.left = box.left + box.width/2 - tooltip.offsetWidth/2 + 'px';
    tooltip.style.top = box.top - tooltip.offsetHeight - 5 + 'px';
    tooltip.style.opacity = 1;

    polygons.forEach( p => p.classList.add('fade'));
    el.classList.remove('fade');
  });

  el.addEventListener('mouseleave', () => {
    document.querySelector('.tooltip').style.opacity = 0;
    polygons.forEach( p => p.classList.remove('fade'));
  });
}

function colorize(d) {
  let dataset = d ? 'for_independence' : 'kanak';
  polygons.forEach( (poly, i) => {
    commune = data.filter( c => c.id == poly.dataset.id )[0];
    poly.style.fill = getColor(commune[dataset]);
  });
  console.log('coloring');
}

function getColor(n) {
  // n --> decimal number
  let colors = ["#de333e", "#ff8F91","#9EACB3","#3661B6","#09306B"];
  let i = n < 0.2 ? 0 :
          n < 0.4 ? 1 :
          n < 0.6 ? 2 :
          n < 0.8 ? 3 : 4;

  return colors[i];
}
