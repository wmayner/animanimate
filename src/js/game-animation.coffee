###
# game-animation.coffee
###

# Initialize interface components
network = require './network'
Animation = require './animation'
environment = require './environment'
Game = require './environment/game'

NUM_SUBFRAMES = 4

exports.init = (network, positions, trials) ->

  # The number of timesteps in a game should be 36, equal to the height of
  # the environment.
  gameLength = trials.Trial[1].lifeTable.length

  trial = 0

  getTrial = -> trial

  # Initialize network.
  animat = network.connectivityToGraph(trials.connectivityMatrix, positions)
  network.load(animat)

  # Animation functions.
  renderSensors = (data, timestep) ->
    # Color Sensors according to on/off.
    state = data.lifeTable[timestep]
    for i in network.nodeTypes.sensors
      node = animat.getNodeByIndex(i)
      animat.setState(node, state[i])
    # Reset the hidden and motors.
    for i in network.nodeTypes.hidden.concat(network.nodeTypes.motors)
      node = animat.getNodeByIndex(i)
      animat.resetNode(node)
    # Update network display.
    network.load(animat)
    return

  renderHidden = (data, timestep) ->
    # Color Hidden units and Motors according to on/off.
    state = data.lifeTable[timestep]
    for i in network.nodeTypes.hidden.concat(network.nodeTypes.motors)
       node = animat.getNodeByIndex(i)
       animat.setState(node, state[i])
    # Reset the sensors.
    for i in network.nodeTypes.sensors
      node = animat.getNodeByIndex(i)
      animat.resetNode(node)
    # Update the network display.
    network.load(animat)
    return

  render = (nextFrame) ->
    trial = nextFrame // (NUM_SUBFRAMES * gameLength)
    # Timestep within a single game.
    timestep = (nextFrame // NUM_SUBFRAMES) % gameLength
    # Timestep within a game timestep.
    internalTimestep = nextFrame % NUM_SUBFRAMES
    switch internalTimestep
      when 0
        if timestep is 0
          # Beginning of game
          game = new Game(trials.Trial[trial], trials.blockSize[trial])
          environment.load(game)
        else
          # Move block.
          environment.updateBlocks()
      when 1
        # Update sensors
        renderSensors(trials.Trial[trial], timestep)
      when 2
        # Update hidden units and motors.
        renderHidden(trials.Trial[trial], timestep)
      else
        # Move animat.
        environment.updateAnimat()
    return

  # Initialize animation.
  animation = new Animation
    render: render
    # 4 (move block, update sensors, updated hidden, move animat)
    # * number of trials * 36
    numFrames: NUM_SUBFRAMES * trials.Trial.length * gameLength - 1
    speed: 8
    speedMultiplier: 2
    timestepFormatter: (timestep) -> "Trial #{getTrial()}"
    timestepSliderStep: NUM_SUBFRAMES * gameLength

  animation.play()
