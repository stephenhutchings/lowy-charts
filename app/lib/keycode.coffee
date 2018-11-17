# Interpret the keyboard command from the keycode

KEY_DELETE  = 8
KEY_TAB     = 9
KEY_ENTER   = 13
KEY_SHIFT   = 16
KEY_CTRL    = 17
KEY_ESCAPE  = 27
KEY_SPACE   = 32
KEY_LEFT    = 37
KEY_UP      = 38
KEY_RIGHT   = 39
KEY_DOWN    = 40
KEY_CMD_L   = 91
KEY_CMD_R   = 93

CHAR_MIN    = "A".charCodeAt(0)
CHAR_MAX    = "Z".charCodeAt(0)
NUM_MIN     = "0".charCodeAt(0)
NUM_MAX     = "9".charCodeAt(0)

module.exports = (e) ->
  modifier  = ""

  if e.shiftKey and e.keyCode isnt KEY_SHIFT
    modifier += "SHIFT_"

  if e.metaKey or e.ctrlKey and
     [KEY_CTRL, KEY_CMD_L, KEY_CMD_R].indexOf(e.keyCode) is -1
    modifier += "META_"

  type =
    switch e.keyCode
      when KEY_DELETE then "DELETE"
      when KEY_TAB    then "TAB"
      when KEY_ENTER  then "ENTER"
      when KEY_SHIFT  then "SHIFT"
      when KEY_ESCAPE then "ESCAPE"
      when KEY_SPACE  then "SPACE"
      when KEY_LEFT   then "LEFT"
      when KEY_UP     then "UP"
      when KEY_RIGHT  then "RIGHT"
      when KEY_DOWN   then "DOWN"
      else
        if CHAR_MIN <= e.keyCode <= CHAR_MAX
          "CHAR_#{String.fromCharCode(e.keyCode)}"
        else if NUM_MIN <= e.keyCode <= NUM_MAX
          "NUM_#{String.fromCharCode(e.keyCode)}"
        else
          "OTHER"

  return modifier + type
