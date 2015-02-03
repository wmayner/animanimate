###
# open-evolution-animation.coffee
###

# Initialize interface components
Chart = require './chart'
colors = require './colors'
Animation = require './animation'

PLOT_COLOR = [
  colors.solarized.red.toString()
  colors.solarized.blue.toString()
  colors.solarized.cyan.toString()
]

GENERATION_STEP = 512

exports.init = (network, positions, json) ->

  $('#chart-module').append (
    "<h2 class='module-title'>" + json.dataLabels[0][i] + '</h2>' +
    "<div class='chart-container'>" +
      "<div class='chart module-canvas' id='chart-" + dataProperty + "'></div>" +
    "</div>" for dataProperty, i in json.dataProperties[0]
  )
  
  charts = (
    new Chart(
      name: json.dataLabels[i]
      bindto: $('#chart-' + dataProperty)[0]
      data: (d[dataProperty] for d in json.generations)
      color: PLOT_COLOR[i]
      min: json.dataAxes[dataProperty][0]
      max: json.dataAxes[dataProperty][1]
      xTickFormat: (x) -> d3.round(x * GENERATION_STEP, 0) 
    ) for dataProperty, i in json.dataProperties[0]
  )

  console.log charts

  # Animation functions.
  render = (nextFrame) ->
    data = json.generations[nextFrame]
    animat = network.connectivityToGraph(data.connectivityMatrix, positions)
    network.load(animat)
    for chart in charts
      chart.load(nextFrame)
    return

  reset = ->
    for chart in charts
      chart.clear()
    return

  # Initialize animation.
  animation = new Animation
    render: render
    reset: reset
    numFrames: json.generations.length
    speed: 6
    speedMultiplier: 1
    timestepFormatter: (timestep) ->
      "Generation #{timestep * GENERATION_STEP}"
    timestepSliderStep: 1

  animation.play()
