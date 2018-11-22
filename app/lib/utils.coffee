module.exports =
  toPercent: (n, d = 0) -> "#{(n * 100).toFixed(d)}%"
  toThousands: (n, d = 0) -> n.toFixed(d).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  toDate: (d, month, day) ->
    if d.toString().match(/^\d{4}$/)
      d = "#{day} #{month} #{d}"
    else if d.match(/^[a-z]+ \d{4}$/i)
      d = "#{day} #{d}"

    new Date(d)
