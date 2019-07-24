_ = require("lodash")
{ Delaunay } = require("d3-delaunay")

module.exports =
  axis: (data) ->
    dist = _.last(data.keys) - data.keys[0]
    data.keys.map (e) =>
      (e - data.keys[0] + 0.5) / (dist + 1) * data.keys.length

  path: (values, data, slice, connect = false) ->
    slice ?= [0]
    axis  = @axis(data)
    dist  = data.scale.max - data.scale.min
    scale = dist / 100

    if slice.length is 1
      while not(_.isNumber(values[slice[0]])) and slice[0] > 0
        slice[0] -= 1

    values.slice(slice...).reduce (m, e, i, a) =>
      points = [
        ((axis[slice[0] + i] / axis.length) * 200).toFixed(2)
        ((100 * scale - (e - data.scale.min)) / scale).toFixed(2)
      ].join(" ")

      if _.isNumber(e)
        op = if _.isNumber(a[i - 1]) or (connect and m) then "L" else "M"
        m += op + points

      m
    , ""

  textOffset: (data, j, i) ->
    values = data.values[j]
    value  = values[i]
    axis   = @axis(data)
    dist   = data.scale.max - data.scale.min

    ap = axis[i-1]
    an = axis[i+1]

    vp = values[i-1] ? value
    vn = values[i+1] ? value

    x1 = ((ap or -an) / values.length) * 100
    x2 = ((an or axis[i] + (axis[i] - ap)) / values.length) * 100
    y1 = 100 * (1 - (vp - data.scale.min) / dist)
    y2 = 100 * (1 - (vn - data.scale.min) / dist)
    t = Math.atan2(y2 - y1, x2 - x1)
    tx = Math.cos(t - Math.PI / 2) * 20 * .75
    ty = Math.sin(0 - Math.PI / 2) * 20

    return { x: tx, ty: y }

  voronoi: (data, bounds = [0, 0, 100, 100]) ->
    axis  = @axis(data)
    points =
      for values, j in data.values
        dist  = data.scale.max - data.scale.min
        scale = dist / 100

        values.reduce (m, e, i, a) =>
          point =
            x: (axis[j] / data.values.length) * bounds[2]
            y: (bounds[3] * scale - (e - data.scale.min)) / scale + i / 1000
            field: i
            key: j
            value: e

          if _.isNumber(e)
            m.push(point)

          return m

        , []

    flat = _.flatten(points)

    for x in axis
      flat.push x: (x / axis.length) * bounds[2], y: -10
      flat.push x: (x / axis.length) * bounds[2], y: bounds[3] + 10

    del = Delaunay.from(flat.map((p) -> [p.x, p.y] ))
    vor = del.voronoi(bounds)

    for point, i in flat.slice(0, flat.length - 1)
      poly = vor.cellPolygon(i)
      sort = (a, b) -> a - b
      [minX, rest..., maxX] = _.pluck(poly, "0").sort(sort)
      [minY, rest..., maxY] = _.pluck(poly, "1").sort(sort)
      point.cx = minX + (maxX - minX) / 2
      point.cy = minY + (maxY - minY) / 2

    {
      points: flat
      voronoi: vor
    }
