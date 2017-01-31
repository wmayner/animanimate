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


$(document).ready ->

  network_config = window.ANIMAT_NETWORK_CONFIG

  if network_config is 'EVOLUTION'
    console.log "Initializing evolution animation."
    console.log "Loading evolution from `#{EVOLUTION_DATA}`..."

    $.getJSON EVOLUTION_DATA, (json) ->
      network.configure(network_config, json.config)
      evolutionAnimation.init(network, json)

  else if network_config is 'GAME'
    console.log "Initializing game animation."
    console.log "Loading game from `#{GAME_DATA}`..."

    $.getJSON GAME_DATA, (json) ->
      network.configure(network_config, json.config)
      gameAnimation.init(network, json)

  # else if network.CONFIG is 'OPENEVOLUTION'
  #   console.log "Initializing open-evolution animation."
  #   $.getJSON 'data/evolutions/Animat32.json', (json) ->
  #     network.nodeTypes = json.nodeTypes
  #     openEvolutionAnimation.init(network, json)

  else
    console.error "Cannot configure network."
