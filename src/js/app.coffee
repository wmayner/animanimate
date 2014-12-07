'use strict'

# Initialize interface components
Chart = require './chart'
network = require './network'
Graph = require './network/graph'

SENSORS = [0, 1]
HIDDEN = [2, 3, 4, 5]
MOTORS = [6, 7]
FIXED_INDICES = SENSORS.concat(HIDDEN).concat(MOTORS)

positions =
 0: {x: 197, y:  88, fixed: true}
 1: {x: 331, y:  88, fixed: true}
 2: {x: 102, y: 183, fixed: true}
 3: {x: 426, y: 183, fixed: true}
 4: {x: 102, y: 317, fixed: true}
 5: {x: 426, y: 317, fixed: true}
 6: {x: 197, y: 412, fixed: true}
 7: {x: 331, y: 412, fixed: true}

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


SPEED = 150

chartWidth = 528
chartHeight = 209

PHI_RANGE = [0, 1.3]
FITNESS_RANGE = [0, 130]

PHI_CHART_ID = 'phi-chart'
FITNESS_CHART_ID = 'fitness-chart'

PLAY_PAUSE_BUTTON_SELECTOR = '#play-pause'

scales =
  phi: d3.scale.linear().domain(PHI_RANGE).nice()
  fitness: d3.scale.linear().domain(FITNESS_RANGE).nice()


$(document).ready ->

  phiChart = new Chart(
    name: 'phi'
    element: document.getElementById(PHI_CHART_ID)
    scale: scales.phi
    width: chartWidth
    height: chartHeight
    color: '#268bd2'
  )
  fitnessChart = new Chart(
    name: 'fitness'
    element: document.getElementById(FITNESS_CHART_ID)
    scale: scales.fitness
    width: chartWidth
    height: chartHeight
    color: '#859900'
  )

  render = (data) ->
    $('#generation').html(data.generation)
    animat = connectivityToGraph(data.connectivityMatrix)
    network.load(animat)
    phiChart.load(data)
    fitnessChart.load(data)
    return

  running = false
  finished = false
  animation = undefined
  generations = undefined
  currentGeneration = 0

  animate = ->
    if currentGeneration < generations.length
      render(generations[currentGeneration])
    else
      clearInterval(animation)
      finished = true
    currentGeneration++

  playAnimation = ->
    running = true
    if finished
      currentGeneration = 0
      phiChart.clear()
      fitnessChart.clear()
    $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
        .removeClass('glyphicon-play')
        .addClass('glyphicon-pause')
    animation = setInterval(animate, SPEED)

  pauseAnimation = ->
    clearInterval(animation)
    $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
        .removeClass('glyphicon-pause')
        .addClass('glyphicon-play')
    running = false

  $.getJSON 'data/generations.json', (json) ->
    generations = json
    network.load(connectivityToGraph(initialConnectivityMatrix))
    $(PLAY_PAUSE_BUTTON_SELECTOR).mouseup ->
      if running
        pauseAnimation()
      else
        playAnimation()
