###
# utils.coffee
###

# Alphabet for letter labels of nodes.
ALPHABET = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
            'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

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

  getLabel: (index, nodeTypes) ->
    if index in nodeTypes.sensors
      return 'S' + (index + 1)
    if index in nodeTypes.hidden
      return ALPHABET[index - nodeTypes.sensors.length]
    if index in nodeTypes.motors
      return 'M' + (index - nodeTypes.sensors.length -
                    nodeTypes.hidden.length + 1)
