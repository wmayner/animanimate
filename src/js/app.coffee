'use strict'

# Initialize interface components
network = require './network'
Chart = require './chart'
Graph = require './network/graph'
colors = require './colors'

FIXED_INDICES = network.SENSORS
  .concat(network.HIDDEN)
  .concat(network.MOTORS)

positions =
 0: {x: 197, y:  88, fixed: true}
 1: {x: 331, y:  88, fixed: true}
 2: {x: 102, y: 225, fixed: true}
 3: {x: 426, y: 225, fixed: true}
 4: {x: 102, y: 375, fixed: true}
 5: {x: 426, y: 375, fixed: true}
 6: {x: 197, y: 520, fixed: true}
 7: {x: 331, y: 520, fixed: true}

initialConnectivityMatrix = [
  [0,0,0,0,0,0,0,0]
  [0,0,0,0,0,0,0,0]
  [0,0,0,0,0,0,0,0]
  [0,0,0,0,0,0,0,0]
  [0,0,0,0,0,0,0,0]
  [0,0,0,0,0,0,0,0]
  [0,0,0,0,0,0,0,0]
  [0,0,0,0,0,0,0,0]
]

connectivityToGraph = (cm) ->
  graph = new Graph()
  for i in [0...cm.length]
    if i in FIXED_INDICES
      graph.addNode(positions[i])
    else
      graph.addNode()
  for i in [0...cm.length]
    for j in [0...cm[i].length]
      if cm[i][j]
        # In the Matlab code, connectivity matrices use the j --> i
        # convention.
        graph.addEdge(j, i)
  return graph


PLAY_PAUSE_BUTTON_SELECTOR = '#play-pause'
GENERATION_SLIDER_SELECTOR = '#generation-slider-container > input.slider'
SPEED_SLIDER_SELECTOR = '#speed-slider-container > input.slider'

displayPlayButton = ->
  $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
      .removeClass('glyphicon-pause')
      .addClass('glyphicon-play')

displayPauseButton = ->
  $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
      .removeClass('glyphicon-play')
      .addClass('glyphicon-pause')


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

GENERATION_STEP = 512

animationSpeed = 150

$(document).ready ->
  # Initialize animation slider.
  $(GENERATION_SLIDER_SELECTOR).slider(
    id: 'generation-slider'
    min: 0
    max: 117
    step: 1
    value: 0
    formatter: (value) -> "Generation #{value * GENERATION_STEP}"
  )
  $(SPEED_SLIDER_SELECTOR).slider(
    id: 'speed-slider'
    reversed: true
    min: 0
    max: 1000
    step: 100
    value: animationSpeed
    formatter: (value) ->
      "Speed: #{d3.round(10 - (value / 100), 0)}"
  )
  # Initialize network.
  network.load(connectivityToGraph(initialConnectivityMatrix))

$.getJSON 'data/generations.json', (generations) ->

  running = false
  frameIndex = 0
  animation = undefined

  charts = [
    new Chart
      name: 'Fitness'
      bindto: FITNESS_CHART_SELECTOR
      data: (d.fitness for d in generations)
      color: FITNESS_COLOR
      min: FITNESS_RANGE[0]
      max: FITNESS_RANGE[1]
      transform: (fitness) -> fitness / MAX_FITNESS
      xTickFormat: (x) -> d3.round(x * GENERATION_STEP, 0)
    new Chart
      name: 'Phi'
      bindto: PHI_CHART_SELECTOR
      data: (d.phi for d in generations)
      color: PHI_COLOR
      min: PHI_RANGE[0]
      max: PHI_RANGE[1]
      xTickFormat: (x) -> d3.round(x * GENERATION_STEP, 0)
    new Chart
      name: 'Number of Concepts'
      bindto: NUM_CONCEPTS_CHART_SELECTOR
      data: (d.numConcepts for d in generations)
      color: NUM_CONCEPTS_COLOR
      min: NUM_CONCEPTS_RANGE[0]
      max: NUM_CONCEPTS_RANGE[1]
      xTickFormat: (x) -> d3.round(x * GENERATION_STEP, 0)
  ]

  updateFrameIndex = (newFrameIndex) ->
    frameIndex = newFrameIndex
    $(GENERATION_SLIDER_SELECTOR).slider('setValue', frameIndex)
    return frameIndex

  render = (frameIndex) ->
    data = generations[frameIndex]
    $('#generation').html(data.generation)
    animat = connectivityToGraph(data.connectivityMatrix)
    network.load(animat)
    for chart in charts
      chart.load(frameIndex)
    return

  finished = -> frameIndex >= generations.length

  animate = ->
    if not finished()
      render(frameIndex)
    else
      clearTimeout(animation)
      displayPlayButton()
    updateFrameIndex(frameIndex + 1)

  handleTick = ->
    animate()
    animation = setTimeout(handleTick, animationSpeed)

  clear = ->
    for chart in charts
      chart.clear()
    updateFrameIndex(0)

  playAnimation = ->
    unless running
      running = true
      displayPauseButton()
      handleTick(animationSpeed)

  pauseAnimation = ->
    clearTimeout(animation)
    displayPlayButton()
    running = false

  handleSpeedSlider = (e) ->
    animationSpeed = e.value
  $(SPEED_SLIDER_SELECTOR)
    .on 'slide', handleSpeedSlider
    .on 'slideStop', handleSpeedSlider
    .data 'slider'

  handleGenerationSlider = (e) ->
      pauseAnimation()
      updateFrameIndex(e.value)
      render(frameIndex)
  $(GENERATION_SLIDER_SELECTOR)
    .on 'slide', handleGenerationSlider
    .on 'slideStop', handleGenerationSlider
    .data 'slider'

  $(PLAY_PAUSE_BUTTON_SELECTOR).mouseup ->
    if running and not finished()
      pauseAnimation()
    else if finished()
      clear()
      playAnimation()
    else
      playAnimation()
