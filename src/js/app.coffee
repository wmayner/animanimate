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


SPEED = 150

chartWidth = 528
chartHeight = 150

PHI_RANGE = [0, 1.3]
NUM_CONCEPTS_RANGE = [0, 8]
FITNESS_RANGE = [0, 1]
MAX_FITNESS = 128

PHI_CHART_ID = 'phi-chart'
FITNESS_CHART_ID = 'fitness-chart'
NUM_CONCEPTS_CHART_ID = 'num-concepts-chart'

PLAY_PAUSE_BUTTON_SELECTOR = '#play-pause'

scales =
  numConcepts: d3.scale.linear().domain(NUM_CONCEPTS_RANGE).nice()
  phi: d3.scale.linear().domain(PHI_RANGE).nice()
  fitness: d3.scale.linear().domain(FITNESS_RANGE).nice()


$(document).ready ->

  fitnessChart = new Chart(
    name: 'fitness'
    element: document.getElementById(FITNESS_CHART_ID)
    scale: scales.fitness
    width: chartWidth
    height: chartHeight
    color: '#ff0000'
    transform: (d) -> d / MAX_FITNESS
  )
  numConceptsChart = new Chart(
    name: 'numConcepts'
    element: document.getElementById(NUM_CONCEPTS_CHART_ID)
    scale: scales.numConcepts
    width: chartWidth
    height: chartHeight
    color: '#859900'
  )
  phiChart = new Chart(
    name: 'phi'
    element: document.getElementById(PHI_CHART_ID)
    scale: scales.phi
    width: chartWidth
    height: chartHeight
    color: '#268bd2'
  )
 

  render = (data) ->
    $('#generation').html(data.generation)
    animat = connectivityToGraph(data.connectivityMatrix)
    network.load(animat)
    phiChart.load(data)
    numConceptsChart.load(data)
    fitnessChart.load(data)
    return

  running = false
  finished = false
  animation = undefined
  generations = undefined
  currentGeneration = 0

  displayPlayButton = ->
    $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
        .removeClass('glyphicon-pause')
        .addClass('glyphicon-play')

  displayPauseButton = ->
    $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
        .removeClass('glyphicon-play')
        .addClass('glyphicon-pause')

  animate = ->
    if currentGeneration < generations.length
      render(generations[currentGeneration])
    else
      clearInterval(animation)
      displayPlayButton()
      finished = true
    currentGeneration++

  clear = ->
    console.log "Clearing graphs"
    currentGeneration = 0
    phiChart.clear()
    numConceptsChart.clear()
    fitnessChart.clear()

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

  $.getJSON 'data/generations.json', (json) ->
    generations = json
    network.load(connectivityToGraph(initialConnectivityMatrix))
    $(PLAY_PAUSE_BUTTON_SELECTOR).mouseup ->
      if running and not finished
        pauseAnimation()
      else if finished
        clear()
        playAnimation()
      else
        playAnimation()
