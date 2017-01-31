'use strict'

# Initialize interface components
network = require './network'
Graph = require './network/graph'
colors = require './colors'

evolutionAnimation = require './evolution-animation'
gameAnimation = require './game-animation'
openEvolutionAnimation = require './open-evolution-animation'

# Data files to load
EVOLUTION_DATA = 'data/evolutions/Animat15.json'
GAME_DATA = 'data/games/game.json'


# Extract node types from JSON config
getNodeTypes = (config) ->
    'sensors': config.SENSOR_INDICES
    'hidden': config.HIDDEN_INDICES
    'motors': config.MOTOR_INDICES

logConfig = (config) ->
    console.log("Loaded configuration:"
    console.log(config)


$(document).ready ->
  # Configure network.
  if window.ANIMAT_NETWORK_CONFIG
    network.CONFIG = window.ANIMAT_NETWORK_CONFIG
  else
    console.error "Cannot configure network."
  console.log "Configured network for: #{network.CONFIG}"

  if network.CONFIG is 'EVOLUTION'
    console.log "Initializing evolution animation."
    console.log "Loading evolution from `#{EVOLUTION_DATA}`..."

    $.getJSON EVOLUTION_DATA, (json) ->
      logConfig(json.config)
      network.nodeTypes = getNodeTypes(json.config)
      evolutionAnimation.init(network, json)

  else if network.CONFIG is 'GAME'
    console.log "Initializing game animation."
    console.log "Loading game from path `#{GAME_DATA}`..."

    $.getJSON GAME_DATA, (json) ->
      logConfig(json.config)
      nodeTypes = getNodeTypes(json.config)
      network.nodeTypes = nodeTypes
      gameAnimation.nodeTypes = nodeTypes
      gameAnimation.init(network, json)

  # else if network.CONFIG is 'OPENEVOLUTION'
  #   console.log "Initializing open-evolution animation."
  #   $.getJSON 'data/evolutions/Animat32.json', (json) ->
  #     network.nodeTypes = json.nodeTypes
  #     openEvolutionAnimation.init(network, json)
