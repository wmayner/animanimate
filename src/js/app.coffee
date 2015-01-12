'use strict'

# Initialize interface components
network = require './network'
Graph = require './network/graph'
colors = require './colors'

evolutionAnimation = require './evolution-animation'
gameAnimation = require './game-animation'

FIXED_INDICES = network.SENSORS
  .concat(network.HIDDEN)
  .concat(network.MOTORS)

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

$(document).ready ->
  # Determine current page.
  page = location.pathname.split('/')[1]

  # Configure network.
  if page.indexOf('evolution') > -1
    network.CONFIG = 'EVOLUTION'
  else if page.indexOf('game') > -1
    network.CONFIG = 'GAME'
  else
    console.error "Not on evolution or game page; cannot configure network."
  console.log "Configured network for: #{network.CONFIG}"

  # Initialize network.
  network.load(connectivityToGraph(initialConnectivityMatrix))

  if network.CONFIG is 'EVOLUTION'
    console.log "Initializing evolution animation."
    evolutionAnimation.init(network, connectivityToGraph)
  else if network.CONFIG is 'GAME'
    console.log "Initializing game animation."
    gameAnimation.init(network, connectivityToGraph)
