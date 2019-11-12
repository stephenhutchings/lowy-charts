$(document).ready ->
  timeout = null
  $("[data-view='in-viewport']")
    .on("load", (e) ->
      timeout = window.setTimeout ->
        e.target.contentWindow?.$("#btn-reset").trigger("click")
        e.target.currentTime = 0
        e.target.pause?()
      , 1000
    )

    .on("enter", (e) ->
      window.clearTimeout timeout
      e.target.contentWindow?.$("#btn-play").trigger("click")
      e.target.currentTime = 0
      timeout = window.setTimeout (-> e.target.play?()), 1000
    )

    .on("exit", (e) ->
      window.clearTimeout timeout
      e.target.contentWindow?.$("#btn-reset").trigger("click")
      e.target.currentTime = 0
      e.target.pause?()
    )
