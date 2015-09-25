'use strict'

# Initialize interface components
network = require './network'
Graph = require './network/graph'
colors = require './colors'

evolutionAnimation = require './evolution-animation'
gameAnimation = require './game-animation'
openEvolutionAnimation = require './open-evolution-animation'

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

positions =
    0: {x: 197, y:  88, fixed: true}
    1: {x: 331, y:  88, fixed: true}
    2: {x: 102, y: 225, fixed: true}
    3: {x: 426, y: 225, fixed: true}
    4: {x: 102, y: 375, fixed: true}
    5: {x: 426, y: 375, fixed: true}
    6: {x: 197, y: 520, fixed: true}
    7: {x: 331, y: 520, fixed: true}

getPositions = (nodeTypes) ->
  for i in nodeTypes.sensors
    positions[i].x = (i % nodeTypes.sensors.length + 1) * (network.WIDTH / (nodeTypes.sensors.length + 1))
    positions[i].y = 88

  for i in nodeTypes.hidden
    # Make 2 rows if there are more than 2 hidden nodes.
    if nodeTypes.hidden.length > 2
      numHidden = nodeTypes.hidden.length
      numSensors = nodeTypes.sensors.length
      # If numHidden does not divide by 2, put less nodes in upper row.
      if (((i - numSensors) % numHidden) + 1) < ((numHidden+1) / 2)
        numNodesInRow = Math.floor(numHidden / 2)
        if (numHidden % 2) > 0 then positions[i].y = 250 else positions[i].y = 225
      else
        numNodesInRow = Math.ceil(numHidden / 2)
        if (numHidden % 2) > 0 then positions[i].y = 350 else positions[i].y = 375
      positions[i].x = ((i % numNodesInRow) + 1) * ((network.WIDTH + 400) / (numNodesInRow + 1)) - 200
    else
      positions[i].x = (i % numHidden + 1) * (network.WIDTH / (numHidden + 1))
      positions[i].y = 300

  for i in nodeTypes.motors
    positions[i].x = (i % nodeTypes.motors.length + 1) * (network.WIDTH / (nodeTypes.motors.length + 1))
    positions[i].y = 520
  return positions

$(document).ready ->
  # Configure network.
  if window.ANIMAT_NETWORK_CONFIG
    network.CONFIG = window.ANIMAT_NETWORK_CONFIG
  else
    console.error "Cannot configure network."
  console.log "Configured network for: #{network.CONFIG}"

  if network.CONFIG is 'EVOLUTION'
    console.log "Initializing evolution animation."
    #$.getJSON 'data/Animat15.json', (json) ->
    $.getJSON 'data/c2a1_change_c23a14_evolution/Animat20_c2a1_change_c23a14.json', (json) ->
      positions = getPositions(json.nodeTypes)
      network.nodeTypes = json.nodeTypes
      evolutionAnimation.init(network, positions, json.generations)
  else if network.CONFIG is 'GAME'
    console.log "Initializing game animation."
    $.getJSON 'data/game.json', (json) ->
      positions = getPositions(json.nodeTypes)
      network.nodeTypes = json.nodeTypes
      gameAnimation.init(network, positions, json)
  else if network.CONFIG is 'OPENEVOLUTION'
    console.log "Initializing open-evolution animation."
    $.getJSON 'data/Animat32.json', (json) ->
      positions = getPositions(json.nodeTypes)
      network.nodeTypes = json.nodeTypes
      openEvolutionAnimation.init(network, positions, json)
