insertCSS = (el) ->
  style = document.createElement("style")
  style.innerHTML = """
    body { background-color: #2d3440; color: #fff; }
    #controls { color: #7e8d94; }
    .btn:hover .btn-icon, .btn:focus .btn-icon { color: #fff; fill: #fff; }
    .country, .background { fill: #1e232b; }
    .map-legend-label-no-data:before { background: #1e232b; border-color: #000; }
    #map-timeline-minimap { background: #2d3440; }
    #map-scale-min, #map-scale-max { background: #1e232b; }
    .country#country-CHN { fill: #dbde00 !important; }
    .country#country-USA { fill: #00fade !important; }
  """

  el.contentDocument.head.appendChild(style)

$(document).ready ->
  timeout = null
  $("[data-view='in-viewport']")
    .on("load", (e) ->
      timeout = window.setTimeout ->
        e.target.contentWindow?.$("#btn-reset").trigger("click")
        e.target.currentTime = 0
        e.target.pause?()
      , 1000

      src = e.target.src

      if src.match "/charts/china-us-trade-dominance/us-china-competition/"
        insertCSS(e.target)
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
