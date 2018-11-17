# Empty style in which we can check for the existence of CSS property support.
emptyStyle = document.createElement("div").style

# Cache prefixes as we find them
vendorPrefixes = {}

getVendorPrefixFor = (style) ->
  s = style.substr(0, 1)
  S = s.toUpperCase()

  for vendor in [s, "webkit#{S}", "Moz#{S}", "ms#{S}", "O#{S}"]
    prefixed = vendor + style.substr(1)
    return vendor.substr(0, vendor.length - 1) if prefixed of emptyStyle

  false

camelCase = (style) ->
  style.replace /\-(\w)/gi, (str, w) -> w.toUpperCase()

prefix = (style) ->
  style = camelCase style
  vendorPrefix = getVendorPrefixFor style

  # This property requires no prefix
  if vendorPrefix is ""
    style

  # Return the stored value or add it to the map if calculating for the
  # first time.
  else if vendorPrefix
    vendorPrefixes[style]?=
      vendorPrefix +
      style.charAt(0).toUpperCase() +
      style.substr(1)

  # This property is not supported at all
  else
    false

# Wrap the prefix function to provide quick access to the good stuff.
module.exports = prefix
