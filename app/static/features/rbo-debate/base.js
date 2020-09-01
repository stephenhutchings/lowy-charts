function readmore() {
  const reveal = document.querySelector('#read-more');
  const btns = document.querySelectorAll('.readmore-label');

  reveal.classList.toggle('lg-max-h');
  btns.forEach( b => {
    b.classList.toggle('hide');
    b.classList.toggle('no-ptr-ev');
  });
}
