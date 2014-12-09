'use strict'

# Initialize interface components
network = require './network'
Chart = require './chart'
Graph = require './network/graph'

SENSORS = [0, 1]
HIDDEN = [2, 3, 4, 5]
MOTORS = [6, 7]
FIXED_INDICES = SENSORS.concat(HIDDEN).concat(MOTORS)

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

PHI_RANGE = [0, 1.3]
NUM_CONCEPTS_RANGE = [0, 8]
FITNESS_RANGE = [0, 1]
MAX_FITNESS = 128

SPEED = 150

$(document).ready ->
  network.load(connectivityToGraph(initialConnectivityMatrix))

$.getJSON 'data/generations.json', (generations) ->

  running = false
  finished = false
  frameIndex = 0
  animation = undefined

  charts = [
    new Chart
      name: 'Fitness'
      bindto: FITNESS_CHART_SELECTOR
      data: (d.fitness for d in generations)
      color: '#7FBF3F'
      min: FITNESS_RANGE[0]
      max: FITNESS_RANGE[1]
      transform: (fitness) -> fitness / MAX_FITNESS
    new Chart
      name: 'Phi'
      bindto: PHI_CHART_SELECTOR
      data: (d.phi for d in generations)
      color: '#3F3FBF'
      min: PHI_RANGE[0]
      max: PHI_RANGE[1]
    new Chart
      name: 'Number of Concepts'
      bindto: NUM_CONCEPTS_CHART_SELECTOR
      data: (d.numConcepts for d in generations)
      color: '#3FBFA5'
      min: NUM_CONCEPTS_RANGE[0]
      max: NUM_CONCEPTS_RANGE[1]
  ]

  render = (data) ->
    $('#generation').html(data.generation)
    animat = connectivityToGraph(data.connectivityMatrix)
    network.load(animat)
    for chart in charts
      chart.load(frameIndex)
    return

  animate = ->
    if frameIndex < generations.length
      render(generations[frameIndex])
    else
      clearInterval(animation)
      displayPlayButton()
      finished = true
    frameIndex++

  clear = ->
    console.log "Clearing graphs"
    frameIndex = 0

  playAnimation = ->
    console.log "Playing animation"
    running = true
    finished = false
    displayPauseButton()
    animation = setInterval(animate, SPEED)

  pauseAnimation = ->
    console.log "Pausing animation"
    clearInterval(animation)
    displayPlayButton()
    running = false

  $(PLAY_PAUSE_BUTTON_SELECTOR).mouseup ->
    if running and not finished
      pauseAnimation()
    else if finished
      clear()
      playAnimation()
    else
      playAnimation()
