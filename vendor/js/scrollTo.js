;(function($){
  var scrollToTopInProgress = false;

  function smooth(pos){
    if ((pos/=0.5) < 1) return 0.5*Math.pow(pos,5)
    return 0.5 * (Math.pow((pos-2),5) + 2)
  }

  $.fn.scrollTo = function(position, callback){
    this
    .each(function(i, el){
      var $this = $(this),
          initialY = $this.scrollTop(),
          maxY = this.scrollHeight - $this.outerHeight(),
          targetY = position,
          lastY = initialY,
          delta = targetY - initialY,
          speed = Math.max(800, Math.min(1200, Math.abs(initialY-targetY))),
          start, t, y, timeout,
          cancelScroll = function(){ abort() },
          frame = window.requestAnimationFrame ||
                  window.webkitRequestAnimationFrame ||
                  window.mozRequestAnimationFrame ||
                  function(callback){ window.setTimeout(callback,15) }

      if (scrollToTopInProgress) return

      $this.on('touchstart', cancelScroll)
      scrollToTopInProgress = true

      function abort(){
        $this.off('touchstart', cancelScroll)
        if (scrollToTopInProgress) {
          scrollToTopInProgress = false
          if (callback) callback($this, true)
        }
      }

      if (delta == 0) {
        abort()
        return
      }

      frame(function render(now){
        if (!scrollToTopInProgress) return
        if (!start) start = now
        t = Math.min(1, Math.max((now - start)/speed, 0))
        y = Math.round(initialY + delta * smooth(t))
        if (delta > 0 && y > targetY) y = targetY
        if (delta < 0 && y < targetY) y = targetY
        if (lastY != y) $this.scrollTop(y)
        lastY = y
        if (y !== targetY) {
          frame(render)
          window.clearTimeout(timeout)
          timeout = window.setTimeout(abort, 100)
        } else {
          window.clearTimeout(timeout)
          abort()
        }
      })
    })
    return this;
  }
})(jQuery || Zepto || $)
