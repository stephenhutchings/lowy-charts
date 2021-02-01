// Globals
var vh = window.innerHeight
var vw = window.innerWidth

var breakpoint = 767
var isFocused = false
var isHeader = false

const get    = (s) => document.querySelector(s)
const getAll = (s) => document.querySelectorAll(s)

const onReady = () => {

  // Elements
  var introTxt = get('#introduction-text')
  var introBtn = get('#introduction .btn-right')

  // Listeners
  window.addEventListener('resize', resize)
  document.addEventListener('scroll', onScroll )
  document.addEventListener('click', e => isFocused ? unfocus(e, this) : "" )
  introBtn.addEventListener('click', (e) => unfold(introTxt, introBtn) )
  introBtn.addEventListener('touch', (e) => unfold(introTxt, introBtn) )
  
  // Initialisation
  setTimeout( () => fold(introTxt, 2), 160)
  setTimeout(initAnimateSort, 1000)
  window.scrollTo(0,0)
  onScroll()

  // Setup
  function resize() {
    
    if ( vw !== window.innerWidth ) {
      vw = window.innerWidth
      spreadY([...getAll('.list-item')])
    }
    
    vh = window.innerHeight
    
  }

  function onScroll() {
    if (window.pageYOffset > 100 && !isHeader) { isHeader = !isHeader; get('header').classList.add('visible') }
    else if (window.pageYOffset <  100 && isHeader) { isHeader = !isHeader; get('header').classList.remove('visible') }
  }

  function fold (d,n) { 
    // fold div 'd' to show first 'n' paragraphs only.
    plist  = d.querySelectorAll('p')
    offset = plist[0].offsetTop
    target = plist[n].offsetTop
    d.style.maxHeight = target - offset + 5 + "px"
  }
    
  function unfold (d, btn) { 
    plist  = d.querySelectorAll('p')
    target = plist[ plist.length - 1 ]
    d.style.maxHeight = target.offsetTop + target.offsetHeight + "px"
    btn.style.display = 'none'
  }

}

document.addEventListener('DOMContentLoaded', onReady)
