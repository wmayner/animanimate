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
SPEED = 100

if SENSORS.length == 2
  console.log SENSORS.length
  positions =
   0: {x: 197, y:  88, fixed: true}
   1: {x: 331, y:  88, fixed: true}
   2: {x: 102, y: 225, fixed: true}
   3: {x: 426, y: 225, fixed: true}
   4: {x: 102, y: 375, fixed: true}
   5: {x: 426, y: 375, fixed: true}
   6: {x: 197, y: 520, fixed: true}
   7: {x: 331, y: 520, fixed: true}
else 
  positions =
   0: {x: 102, y:  88, fixed: true}
   1: {x: 264, y:  88, fixed: true}
   2: {x: 426, y:  88, fixed: true}
   3: {x: 102, y: 275, fixed: true}
   4: {x: 264, y: 375, fixed: true}
   5: {x: 426, y: 275, fixed: true}
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

$(document).ready ->

  render = (counter, cT) ->
    $('#trial').html(cT+1)
    timeStep = (counter // 4)%(timeStepInterval)
    $('#time-step').html(timeStep+1)
    internalStep = counter%4
    switch internalStep
        when 0
          #move block
          if timeStep == 0
            #console.log trials.Trial[cT]
            game = new Game(trials.Trial[cT], trials.blockSize[cT])
            environment.load(game)
          else
            # 1) move block
            environment.update()  
        when 1
          #update Sensors
          renderSensors(trials.Trial[cT], timeStep)
        when 2 
          #update hidden and motors
          renderHidden(trials.Trial[cT], timeStep)
        else
          #move animat
          environment.updateAnimat()
    return

  renderSensors = (data, ts) ->
    # color Sensors according to on/off
    state = data.lifeTable[ts]
    for i in SENSORS
      node = currentAnimat.getNodeByIndex(i)
      currentAnimat.setState(node, state[i])
    for i in HIDDEN.concat(MOTORS)
      node = currentAnimat.getNodeByIndex(i)
      currentAnimat.resetNode(node)
    network.load(currentAnimat)
    return

  renderHidden = (data, ts) ->
    # color Hidden units and Motors according to on/off
    state = data.lifeTable[ts]
    for i in SENSORS
      node = currentAnimat.getNodeByIndex(i)
      currentAnimat.resetNode(node)
    for i in HIDDEN.concat(MOTORS)
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
  maxAnimationSteps = 0

  displayPlayButton = ->
    $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
        .removeClass('glyphicon-pause')
        .addClass('glyphicon-play')

  displayPauseButton = ->
    $("#{PLAY_PAUSE_BUTTON_SELECTOR} > span")
        .removeClass('glyphicon-play')
        .addClass('glyphicon-pause')

  animate = ->
    if animationCounter < maxAnimationSteps
      render(animationCounter, currentTrial)
    else
      clearInterval(animation)
      displayPlayButton()
      finished = true
    animationCounter++
    if animationCounter%(4*timeStepInterval) == 0 
      currentTrial++

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
    # The timeStepInterval should be 36, equal to the height of the environment
    timeStepInterval = trials.Trial[1].lifeTable.length
    # 4 (move block, update sensors, updated hidden, move animat) * number of trials * 36
    maxAnimationSteps = 4*trials.Trial.length*timeStepInterval
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
