'use strict'

# Initialize interface components
network = require './network'
Graph = require './network/graph'
colors = require './colors'

evolutionAnimation = require './evolution-animation'
gameAnimation = require './game-animation'
openEvolutionAnimation = require './open-evolution-animation'


# Extract node types from JSON config
getNodeTypes = (config) ->
    'sensors': config.SENSOR_INDICES
    'hidden': config.HIDDEN_INDICES
    'motors': config.MOTOR_INDICES


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
      network.nodeTypes = getNodeTypes(json.config)
      evolutionAnimation.init(network, json)

  else if network.CONFIG is 'GAME'
    console.log "Initializing game animation."

    # measure = 'mat-from-scratch'
    # scrambled = no
    # seed = 4
    # ngen = 60000
    # snapshot = no
    # snapshot = '-1'
    #
    # version = '0.0.20'
    # task = '3-4-6-5'
    # sensors = 3
    # jumpstart = 0
    #
    # path = "data/compiled_results/#{version}/#{measure}/#{task}/sensors-#{sensors}/jumpstart-#{jumpstart}/ngen-#{ngen}/seed-#{seed}/#{if snapshot then 'snapshot-' + snapshot + '/' else ''}game#{if scrambled then '-scrambled' else ''}.json"

    path = "data/games/game.json"
    console.log "Loading game from path `#{path}`..."
    $.getJSON path, (json) ->
      console.log "Loaded game with configuration:"
      console.log json.config
      nodeTypes = getNodeTypes(json.config)
      network.nodeTypes = nodeTypes
      gameAnimation.nodeTypes = nodeTypes
      gameAnimation.init(network, json)
  else if network.CONFIG is 'OPENEVOLUTION'
    console.log "Initializing open-evolution animation."
    $.getJSON 'data/evolutions/Animat32.json', (json) ->
      network.nodeTypes = json.nodeTypes
      openEvolutionAnimation.init(network, json)
