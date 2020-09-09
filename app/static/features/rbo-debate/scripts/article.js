let breakpoint = 540;

document.addEventListener('DOMContentLoaded', onload);
document.addEventListener('click', closeModal);
document.addEventListener('keydown', onKeydown);
window.addEventListener('resize', onsize);

function onload() {
  trimTitleNbsp();
  infographic();
}

function onsize() {
  trimTitleNbsp();
}

function onKeydown(e) {
  e.key == "Escape" ? closeModal() : "";
}

function infographic() {

  document.querySelectorAll('cite').forEach( function(el, i) {
    el.addEventListener('click', function(e) {
      let id = `#infographic-${el.dataset.graph}`;
      let chart = document.querySelector(id).parentElement;
      chart.classList.add('active');
      chart.style.display = 'block';
      e.stopPropagation();
    });
  });
}

function closeModal() {
  let active = document.querySelector('.active');
  if (active) {
    active.style.display = 'none';
    active.classList.remove('active');
  }
}

function trimTitleNbsp() {
  if (window.innerWidth < breakpoint) {
    let title = document.querySelector('.article-landing h1')
    let str = title.innerHTML;
    title.innerHTML = str.replace('&nbsp;', ' ');
  }
}
