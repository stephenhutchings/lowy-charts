let breakpoint = 540;
let isHeader = false;

document.addEventListener('DOMContentLoaded', onload);
document.addEventListener('scroll', scroll);
window.addEventListener('resize', onsize);

function onload() {
  trimTitleNbsp();
  setModal();
}

function onsize() {
  trimTitleNbsp();
}

function scroll() {
  let trigger = window.innerHeight - window.pageYOffset < 0;
  if (trigger && !isHeader) { isHeader = !isHeader; document.querySelector('header').style.opacity = 1 }
  else if (!trigger && isHeader) { isHeader = !isHeader; document.querySelector('header').style.opacity = 0 }
}

function trimTitleNbsp() {
  if (window.innerWidth < breakpoint) {
    let title = document.querySelector('.article-landing h1')
    let str = title.innerHTML;
    title.innerHTML = str.replace('&nbsp;', ' ');
  }
}
