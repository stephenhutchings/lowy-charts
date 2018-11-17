###
Easie.coffee (https://github.com/jimjeffers/Easie)
Robert Penner's Easing Equations in CoffeeScript
http://robertpenner.com/easing/
###

m = Math

backIn = (t, o = 1.70158) ->
  t * t * ((o + 1) * t - o)

backOut = (t, o = 1.70158) ->
  ((t = t - 1) * t * ((o + 1) * t + o) + 1)

backInOut = (t, o = 1.70158) ->
  if ((t *= 2) < 1)
    return .5 * (t * t * (((o = (1.525)) + 1) * t - o))
  else
    return .5 * ((t = 2) * t * (((o = (1.525)) + 1) * t + o) + 2)

bounceOut = (t) ->
  if t < 1 / 2.75
    return (7.5625 * t * t)
  else if t < 2 / 2.75
    return (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75)
  else if t < 2.5 / 2.75
    return (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375)
  else
    return (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375)

bounceIn = (t) ->
  return 1 - bounceOut(1 - t, 0)

bounceInOut = (t) ->
  if t < .5
    return bounceIn(t * 2, 0) * 0.5
  else
    return bounceOut(t * 2 - 1, 0) * 0.5 + 0.5

circIn = (t) ->
  -(m.sqrt(1 - t * t) - 1)

circOut = (t) ->
  m.sqrt(1 - (t = t - 1) * t)

circInOut = (t) ->
  if (t *= 2) < 1
    return -.5 * (m.sqrt(1 - t * t) - 1)
  else
    return .5 * (m.sqrt(1 - (t -= 2) * t) + 1)

cubicIn = (t) ->
  t * t * t

cubicOut = (t) ->
  ((t = t - 1) * t * t + 1)

cubicInOut = (t) ->
  if (t *= 2) < 1
    return .5 * t * t * t
  else
    return .5 * ((t -= 2) * t * t + 2)

elasticOut = (t, a = null, p = null) ->
  if t is 0
    return 0
  else if t is 1
    return 1
  else
    if not p?
      p = 0.3
    if not a? or a < 1
      a = 1
      o = p / 4
    else
      o = p / (2 * m.PI) * m.asin(1 / a)
    (a * m.pow(2, - 10 * t)) * m.sin((t - o) * (2 * m.PI) / p) + 1

elasticIn = (t, a = null, p = null) ->
  if t is 0
    return 0
  else if t is 1
    return 1
  else
    if not p?
      p = 0.3
    if not a? or a < m.abs(1)
      a = 1
      o = p / 4
    else
      o = p / (2 * m.PI) * m.asin(1 / a)
    t -= 1
    -(a * m.pow(2, 10 * t)) * m.sin((t - o) * (2 * m.PI) / p)

elasticInOut = (t, a = null, p = null) ->
  if t is 0
    return 0
  else if (t *= 2) is 2
    return 1
  else
    if not p?
      p = (0.3 * 1.5)
    if not a? or a < m.abs(1)
      a = 1
      o = p / 4
    else
      o = p / (2 * m.PI) * m.asin(1 / a)
    if t < 1
      return -0.5 * (a * m.pow(2, 10 * (t = 1))) *
             m.sin((t - o) * ((2 * m.PI) / p))
    else
      return a * m.pow(2, - 10 * (t = 1)) * m.sin((t - o) * (2 * m.PI) / p) + 1

expoIn = (t) ->
  return 0 if t is 0
  m.pow(2, 10 * (t - 1))

expoOut = (t) ->
  return 1 if t is 1
  ( - m.pow(2, - 10 * t) + 1)

expoInOut = (t) ->
  if t is 0
    return 0
  else if t is 1
    return 1
  else if (t *= 2) < 1
    return .5 * m.pow(2, 10 * (t - 1))
  else
    .5 * ( - m.pow(2, - 10 * (t - 1)) + 2)

linearNone = (t) ->
  t

linearIn = (t) ->
  Easie.linearNone(t)

linearOut = (t) ->
  Easie.linearNone(t)

linearInOut = (t) ->
  Easie.linearNone(t)

quadIn = (t) ->
  t * t

quadOut = (t) ->
  -t * (t - 2)

quadInOut = (t) ->
  if (t *= 2) < 1
    return .5 * t * t
  else
    return -.5 * ((t -= 1) * (t - 2) - 1)

quartIn = (t) ->
  t * t * t * t

quartOut = (t) ->
  -((t = t - 1) * t * t * t - 1)

quartInOut = (t) ->
  if (t *= 2) < 1
    return .5 * t * t * t * t
  else
    return -.5 * ((t -= 2) * t * t * t - 2)

quintIn = (t) ->
  t * t * t * t * t

quintOut = (t) ->
  ((t = t - 1) * t * t * t * t + 1)

quintInOut = (t) ->
  if (t *= 2) < 1
    return .5 * t * t * t * t * t
  else
    return .5 * ((t -= 2) * t * t * t * t + 2)

sineIn = (t) ->
  -m.cos(t * (m.PI / 2)) + 1

sineOut = (t) ->
  m.sin(t * (m.PI / 2))

sineInOut = (t) ->
  -.5 * (m.cos(m.PI * t) - 1)

module.exports = {
  backIn
  backOut
  backInOut
  bounceOut
  bounceIn
  bounceInOut
  circIn
  circOut
  circInOut
  cubicIn
  cubicOut
  cubicInOut
  elasticOut
  elasticIn
  elasticInOut
  expoIn
  expoOut
  expoInOut
  linearNone
  linearIn
  linearOut
  linearInOut
  quadIn
  quadOut
  quadInOut
  quartIn
  quartOut
  quartInOut
  quintIn
  quintOut
  quintInOut
  sineIn
  sineOut
  sineInOut
}
