$(document).ready(function () {
  let vw = window.innerWidth

  let wrap = document.querySelector(".wrapper")
  let pos = document.querySelector(".move-pos")
  let neg = document.querySelector(".move-neg")

  let l = wrap.getBoundingClientRect().left
  let w = wrap.getBoundingClientRect().width
  let mouseDown = false

  let maintainAspectRatio = function () {
    vw < 800 ? (wrap.style.height = 0.75 * vw + "px") : ""
  }

  window.onload = maintainAspectRatio
  window.addEventListener("resize", () => {
    vw = window.innerWidth
    l = wrap.getBoundingClientRect().left
    w = wrap.getBoundingClientRect().width
    maintainAspectRatio()
  })

  window.addEventListener("mousemove", slide)
  window.addEventListener("touchmove", slide)
  window.addEventListener("mouseup", stop)
  window.addEventListener("touchend", stop)

  wrap.addEventListener("mousedown", start)
  wrap.addEventListener("touchstart", start)

  function start(e) {
    mouseDown = true
    slide(e)
  }

  function slide(e) {
    if (mouseDown) {
      e = e.touches ? e.touches[0] : e
      let x = e.pageX - l
      x = Math.min(Math.max(x, 0), w)
      pos.style.transform = `translate3d(${x}px, 0, 0)`
      neg.style.transform = `translate3d(${-x}px, 0, 0)`
      wrap.classList.add("active")
    }
  }

  function stop(e) {
    mouseDown = false
    wrap.classList.remove("active")
  }
})
