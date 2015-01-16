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
    label: d3.rgb 68, 68, 68
  link:
    line: d3.rgb 0, 0, 0
    endpoint: d3.rgb 130, 130, 130
  block: '#444'
  animat: solarized.cyan
