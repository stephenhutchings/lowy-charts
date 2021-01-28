// Globals
var vh = window.innerHeight
var vw = window.innerWidth

var breakpoint = 768
var isFocused = false
var isHeader = false

const get    = (s) => document.querySelector(s)
const getAll = (s) => document.querySelectorAll(s)

const onReady = () => {

  // Elements
  var introTxt = get('#introduction')
  var introBtn = get('#introduction .btn-right')

  // Listeners
  window.addEventListener('resize', resize)
  document.addEventListener('scroll', onScroll )
  document.addEventListener('click', e => isFocused ? unfocus(e, this) : "" )
  introBtn.addEventListener('click', (e) => unfold(introTxt, introBtn) )
  introBtn.addEventListener('touch', (e) => unfold(introTxt, introBtn) )
  
  // Initialisation
  setTimeout( () => fold(introTxt, 2), 100)
  setTimeout(initAnimateSort, 1000)
  window.scrollTop = 0
  onScroll()

  // Setup
  function resize() {
    vw = window.innerWidth
    vh = window.innerHeight
    spreadY([...document.querySelectorAll('.list-item')])
  }

  function onScroll() {
    if (window.pageYOffset > 100 && !isHeader) { isHeader = !isHeader; document.querySelector('header').style.opacity = 1 }
    else if (window.pageYOffset <  100 && isHeader) { isHeader = !isHeader; document.querySelector('header').style.opacity = 0 }
  }

  function fold (d,n) { 
    // fold div 'd' to show first 'n' paragraphs only.
    plist  = d.querySelectorAll('p')
    offset = plist[0].offsetTop
    target = plist[n].offsetTop
    d.style.maxHeight = target - offset + "px"
    console.log(offset, target)
  }
    
  function unfold (d, btn) { 
    plist  = d.querySelectorAll('p')
    target = plist[ plist.length - 1 ]
    d.style.maxHeight = target.offsetTop + target.offsetHeight + "px"
    btn.style.display = 'none'
  }

}

document.addEventListener('DOMContentLoaded', onReady)
