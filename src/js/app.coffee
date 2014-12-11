'use strict'

# Initialize interface components
Chart = require './chart'
network = require './network'
Graph = require './network/graph'
environment = require './environment'
Game = require './environment/game'

SENSORS = [0, 1]
HIDDEN = [2, 3, 4, 5]
MOTORS = [6, 7]
FIXED_INDICES = SENSORS.concat(HIDDEN).concat(MOTORS)
CURRENT_GENERATION = 59904

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

# locationToBlocks = (ts, blockSize) ->
#   block = new Blocks()
#   for i in blockSize
#       block.addBox(positions[i])   
#   return block

SPEED = 150

PLAY_PAUSE_BUTTON_SELECTOR = '#play-pause'

$(document).ready ->

  render = (ts, direction) ->
     # set block and animat to right position
    game = new Game() #where?
    game.moveBlock([ts, ])
    game.addBlock([ts, 0], blockSize) 
    # animat = connectivityToGraph(data.connectivityMatrix)
    # environment.load(animat)
    return

  render2 = (data, ts) ->
    $('#time-step').html(ts+1)
    # color nodes according to on/off
    state = data.lifeTable[ts]
    for i in FIXED_INDICES
      node = currentAnimat.getNodeByIndex(i)
      currentAnimat.setState(node, state[i])
    network.load(currentAnimat)
    return

  running = false
  finished = false
  animation = undefined
  generations = undefined
  trials = undefined
  currentAnimat = undefined
  currentGeneration = 0
  currentTrial = 0
  animationCounter = 0
  timeStepInterval = 0

  displayPlayButton = ->
    $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
        .removeClass('glyphicon-pause')
        .addClass('glyphicon-play')

  displayPauseButton = ->
    $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
        .removeClass('glyphicon-play')
        .addClass('glyphicon-pause')

  animate = ->
    # if currentGeneration < generations.length
    #   render(generations[currentGeneration])
    # else
    #   clearInterval(animation)
    #   displayPlayButton()
    #   finished = true
    # currentGeneration++

    if animationCounter < trials.Trial.length*timeStepInterval
      $('#trial').html(currentTrial)
      timeStep = animationCounter%timeStepInterval
      game = new Game
      if timeStep == 0
        game.addBlock([timeStep, 0], trials.blockSize[animationCounter])  
        #set animat position
      else
        direction = currentTrial%16
        #game.moveBlock(direction)
        #render(trials.Trial[currentTrial], timeStep, trials.blockSize[animationCounter], direction)
      render2(trials.Trial[currentTrial], timeStep)
      if animationCounter%timeStepInterval == 0 
        currentTrial++
    else
      clearInterval(animation)
      displayPlayButton()
      finished = true
    animationCounter++

  clear = ->
    console.log "Clearing graphs"
    currentGeneration = 0
    currentTrial = 0

    
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

  $.getJSON 'data/AnimatBlockTrials32_59904.json', (json) ->
    trials = json
    timeStepInterval = trials.Trial[1].lifeTable.length
    currentAnimat = connectivityToGraph(trials.connectivityMatrix)
    network.load(currentAnimat)
    $(PLAY_PAUSE_BUTTON_SELECTOR).mouseup ->
      if running and not finished
        pauseAnimation()
      else if finished
        clear()
        playAnimation()
      else
        playAnimation()
