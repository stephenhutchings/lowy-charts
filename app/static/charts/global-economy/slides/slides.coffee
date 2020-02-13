insertCSS = (el) ->
  style = document.createElement("style")
  style.innerHTML = """
    body { background-color: #fff; color: #333; }

    #wrapper:before { content: none }
    #axis-years:before {
      background: linear-gradient(to bottom, #fff 100px, rgba(255, 255, 255, 0));
    }
    #axis-years:after {
      background: linear-gradient(to bottom, rgba(255, 255, 255, 0), #fff);
    }
    #controls:before, #controls:after { border-color: #ccc; }
    #controls:after, #axis-x:after, #axis-year:after { background: #fff; }
    .txt-us { color: #0056fa; }
    .country.country-us { stroke: #0056fa; }
    .country-us .country-label-text { background: #0056fa;}
    .txt-cn { color: #fa0051; }
    .country.country-cn { stroke: #fa0051; }
    .country-cn .country-label-text { background: #fa0051;}
    .country-label-text { color: #fff; }

    .chart-title-label line { stroke: #333; }
    .year.active, .year:hover { color: #333; }
    .btn-icon:hover, .btn-icon:focus { fill: #333; }
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

        src = e.target.src

        if src.match "/charts/api/me-china-vs-us/"
          insertCSS(e.target)
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
