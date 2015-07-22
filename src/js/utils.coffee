###
# utils.coffee
###

module.exports =

  bit: (bool) -> (if bool then 1 else 0)

  negate: (bool) -> (if bool then 0 else 1)

  any: (array) ->
    for element in array
      if element
        return true
    return false

  all: (array) ->
    for element in array
      if not element
        return false
    return true

  dict: (pairs) ->
    dict = {}
    dict[key] = value for [key, value] in pairs
    return dict
