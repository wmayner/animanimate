'use strict'

# Initialize interface components
network = require './network'
Graph = require './network/graph'
colors = require './colors'

evolutionAnimation = require './evolution-animation'
gameAnimation = require './game-animation'
openEvolutionAnimation = require './open-evolution-animation'


$(document).ready ->
  # Configure network.
  if window.ANIMAT_NETWORK_CONFIG
    network.CONFIG = window.ANIMAT_NETWORK_CONFIG
  else
    console.error "Cannot configure network."
  console.log "Configured network for: #{network.CONFIG}"

  if network.CONFIG is 'EVOLUTION'
    console.log "Initializing evolution animation."
    $.getJSON 'data/evolutions/Animat15.json', (json) ->
      network.nodeTypes = json.nodeTypes
      evolutionAnimation.init(network, json.generations)
  else if network.CONFIG is 'GAME'
    console.log "Initializing game animation."
    seed = 13
    $.getJSON "data/compiled_results/0.0.15/nat/3-4-6-5/sensors-3/jumpstart-4/gen-60000/seed-#{seed}/game.json", (json) ->
      console.log "Loaded game with configuration:"
      console.log json.config
      nodeTypes =
        'sensors': json.config.SENSOR_INDICES
        'hidden': json.config.HIDDEN_INDICES
        'motors': json.config.MOTOR_INDICES
      network.nodeTypes = nodeTypes
      gameAnimation.init(network, json)
  else if network.CONFIG is 'OPENEVOLUTION'
    console.log "Initializing open-evolution animation."
    $.getJSON 'data/evolutions/Animat32.json', (json) ->
      network.nodeTypes = json.nodeTypes
      openEvolutionAnimation.init(network, json)
