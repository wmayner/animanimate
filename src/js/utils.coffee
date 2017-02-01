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

  last: (array) ->
    return array[array.length - 1]

  dict: (pairs) ->
    dict = {}
    dict[key] = value for [key, value] in pairs
    return dict

  getLabel: (index, config) ->
    if index in config.SENSOR_INDICES
      return 'S' + (index + 1)
    if index in config.HIDDEN_INDICES
      return ALPHABET[index - config.SENSOR_INDICES.length]
    if index in config.MOTOR_INDICES
      return 'M' + (index - config.SENSOR_INDICES.length -
                    config.HIDDEN_INDICES.length + 1)
