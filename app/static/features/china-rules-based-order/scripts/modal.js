document.addEventListener('click', closeModal);
document.addEventListener('keydown', onKeydown);

function onKeydown(e) {
  e.key == "Escape" ? closeModal() : "";
}

function setModal() {
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
