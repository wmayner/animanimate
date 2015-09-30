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
    $.getJSON 'data/c2a1_change_c23a14_evolution/Animat179_c2a1_change_c23a14.json', (json) ->
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
    
    files = [
             'Animat20_c2a1_change_c23a14.json',
             'Animat26_c2a1_change_c23a14.json',
             'Animat27_c2a1_change_c23a14.json',
             'Animat38_c2a1_change_c23a14.json',
             'Animat64_c2a1_change_c23a14.json',
             'Animat65_c2a1_change_c23a14.json',
             'Animat78_c2a1_change_c23a14.json',
             'Animat80_c2a1_change_c23a14.json',
             'Animat129_c2a1_change_c23a14.json',
             'Animat132_c2a1_change_c23a14.json',
             'Animat148_c2a1_change_c23a14.json',
             'Animat167_c2a1_change_c23a14.json',
             'Animat174_c2a1_change_c23a14.json',
             'Animat179_c2a1_change_c23a14.json',
             'Animat185_c2a1_change_c23a14.json',
             'Animat196_c2a1_change_c23a14.json',
            ]

    base_dest = 'data/c2a1_change_c23a14_evolution'

    document.click_list = (location) ->
      document.location.href = '?file=' + location + '&gen=' + (animation.nextFrame-1)

    $('#json-list').append(
      '<li><a onclick=click_list("' + name + '")>' + name + '</a></li>' for name in files
    )
   
    queryDict = {}
    location.search.substr(1).split("&").forEach( (item) -> queryDict[item.split("=")[0]] = item.split("=")[1] )
    current_file = base_dest + '/' + queryDict['file']
    $('#current-file').append(queryDict['file'])

    index_of_file = files.indexOf(queryDict['file'])
    nextFrame = parseInt(queryDict['gen'])
            
    $('#go-left').click( ->
      document.location.href = '?file=' + files[if index_of_file >1 then index_of_file - 1 else index_of_file] + '&gen=' + (animation.nextFrame-1)
      )
                                    
    $('#go-right').click( ->
      document.location.href = '?file=' + files[if index_of_file < files.length-1 then index_of_file + 1 else index_of_file] + '&gen=' + (animation.nextFrame-1)
      )

      
    animation = $.getJSON current_file, (json) ->
      positions = getPositions(json.nodeTypes)
      network.nodeTypes = json.nodeTypes
      animation = openEvolutionAnimation.init(network, positions, json, nextFrame)
      animation
