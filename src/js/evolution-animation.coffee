###
# evolution-animation.coffee
###

# Initialize interface components
Chart = require './chart'
colors = require './colors'
Animation = require './animation'
utils = require './utils'


PHI_CHART_SELECTOR = '#phi-chart'
FITNESS_CHART_SELECTOR = '#fitness-chart'

NUM_CONCEPTS_CHART_SELECTOR = '#num-concepts-chart'
FITNESS_COLOR = colors.solarized.red.toString()
PHI_COLOR = colors.solarized.blue.toString()
NUM_CONCEPTS_COLOR = colors.solarized.cyan.toString()

PHI_RANGE = [0, 1.25]
NUM_CONCEPTS_RANGE = [0, 8]
FITNESS_RANGE = [0, 1]
MAX_FITNESS = 128


exports.init = (network, json) ->

  generations = json.lineage
  config = json.config

  step = utils.last(generations).generation / (generations.length - 1)

  xTick = (x) ->
      return d3.round(x * step, 0)

  charts = [
    new Chart
      name: 'Fitness'
      bindto: FITNESS_CHART_SELECTOR
      data: (d.fitness for d in generations)
      color: FITNESS_COLOR
      min: FITNESS_RANGE[0]
      max: FITNESS_RANGE[1]
      dataTransform: (fitness) -> fitness / MAX_FITNESS
      xTickFormat: xTick
    new Chart
      name: 'Phi'
      bindto: PHI_CHART_SELECTOR
      data: (d.phi for d in generations)
      color: PHI_COLOR
      min: PHI_RANGE[0]
      max: PHI_RANGE[1]
      xTickFormat: xTick
    new Chart
      name: 'Number of Concepts'
      bindto: NUM_CONCEPTS_CHART_SELECTOR
      data: (d.numConcepts for d in generations)
      color: NUM_CONCEPTS_COLOR
      min: NUM_CONCEPTS_RANGE[0]
      max: NUM_CONCEPTS_RANGE[1]
      xTickFormat: xTick
  ]

  # Animation functions.
  render = (nextFrame) ->
    data = generations[nextFrame]
    animat = network.graphFromJson(data, json.config)
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
    numFrames: generations.length
    speed: 6
    speedMultiplier: 1
    timestepFormatter: (timestep) ->
      "Generation #{timestep * step}"
    timestepSliderStep: 1

  animation.play()
