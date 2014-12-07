'use strict'

Graph = require './network/graph'


# Initialize interface components
network = require './network'
chart = require './chart'

connectivityMatrix = [
  [0,0,0,0,0,0,0,0]
  [0,0,0,0,0,0,0,0]
  [0,0,0,0,0,0,0,0]
  [1,0,0,1,1,1,0,0]
  [1,1,0,1,1,1,0,0]
  [1,0,0,1,1,1,0,0]
  [1,0,0,1,1,1,0,0]
  [0,1,0,1,0,0,0,0]
]


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
        # j --> i
        graph.addEdge(j, i)
  return graph


render = (data) ->
  $('#generation').html(data.generation)
  animat = connectivityToGraph(data.connectivityMatrix)
  network.load(animat)
  chart.load(data)
  return


timeStep = 100


$(document).ready ->
  chart.init()

  $.getJSON 'data/generations.json', (generations) ->
    i = 0
    animation = setInterval(
      (->
        if i < generations.length
          render(generations[i])
        i++
      ),
      timeStep
    )
