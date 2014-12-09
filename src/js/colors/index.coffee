###
# colors/index.coffee
###

solarized = require './solarized'

module.exports =
  solarized: solarized
  node:
    sensor: d3.rgb 122, 228, 122
    hidden: d3.rgb 236, 233, 54
    motor: d3.rgb 220, 80, 80
    other: solarized.base1
