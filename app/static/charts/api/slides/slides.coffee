$(document).ready ->
  $("iframe")
    .on("load", (e) ->
      window.setTimeout ->
        e.target.contentWindow.$("#btn-reset").trigger("click")
      , 1000
    )

    .on("enter", (e) ->
      window.setTimeout ->
        e.currentTarget.contentWindow.$("#btn-play").trigger("click")
      , 0
    )

    .on("exit", (e) ->
      window.setTimeout ->
        e.currentTarget.contentWindow.$("#btn-reset").trigger("click")
      , 0
    )
