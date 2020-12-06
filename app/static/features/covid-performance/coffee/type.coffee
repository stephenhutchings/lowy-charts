require.register "TextScramble", (exports, require, module) ->

  mrand  = ()  -> Math.random()
  mfloor = (v) -> Math.floor(v)

  class TextScramble

    constructor: (el) ->
      
      @el = el
      @chars  = '!<>-_\\/[]{}—=+*^?#___'
      @update = @update.bind(this)
      
  
    set: (txt) ->      

      @queue = []
      old = @el.innerText
      len = Math.max old.length, txt.length
      
      promise = new Promise (resolve) => this.resolve = resolve
      
      for i in [0..(len-1)]
        oc  = old[i] or ''
        nc  = txt[i] or ''
        st  = mfloor( mrand() * 10 )
        end = mfloor( mrand() * 0 ) + st
        @queue.push { oc, nc, st, end }
      
      cancelAnimationFrame(@frameRequest)
      @frame = 0
      @update()
      
      return promise
    
    update: ->
      
      output = ''
      complete = 0
      l = @queue.length
      
      for i in [0..(l-1)]

        { oc, nc, st, end, char } = @queue[i]
        
        if @frame >= end
          complete++
          output += nc
          
        else if @frame >= st
          if mrand() < 0.28 or not char
            char = @rand()
            @queue[i].char = char
          output += "<span class='txt-dark'>#{char}</span>"
          
         else
           output += oc
      
      @el.innerHTML = output
      
      if l is complete then @resolve()
      else
        @frameRequest = requestAnimationFrame(@update)
        @frame++


    rand: -> @chars[ ~~( @chars.length*mrand() ) ]

  module.exports = TextScramble
  
