###
# game-animation.coffee
###

# Initialize interface components
network = require './network'
Animation = require './animation'
environment = require './environment'

NUM_SUBFRAMES = 3

exports.init = (network, positions, json) ->
  # Tell the environment the game parameters.
  environment.loadConfig(json.config)

  # The number of timesteps in a game should be equal to the height of the
  # environment.
  gameLength = json.config.WORLD_HEIGHT

  trialNum = 0

  getTrialNum = -> trialNum

  # Initialize network.
  animat = network.connectivityToGraph(json.cm, positions)
  network.load(animat)

  # Animation functions.
  renderSensors = (frame) ->
    # Color Sensors according to on/off.
    state = frame.animat
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

  renderHiddenAndMotors = (frame) ->
    # Color hidden and motor units according to on/off.
    state = frame.animat
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
    # Trial number.
    trialNum = nextFrame // (NUM_SUBFRAMES * gameLength)
    # Current trial.
    trial = json.trials[trialNum]
    # Timestep within the trial.
    timestep = (nextFrame // NUM_SUBFRAMES) % gameLength
    # Subtimestep within a timestep.
    internalTimestep = nextFrame % NUM_SUBFRAMES
    # Current game state.
    gameState = trial.timesteps[timestep]
    switch internalTimestep
      when 0
        # Update game state.
        environment.update(trial, timestep)
      when 1
        # Update sensors.
        renderSensors(trial.timesteps[timestep])
      when 2
        # Update hidden units and motors.
        renderHiddenAndMotors(trial.timesteps[timestep])
    return

  # Initialize animation.
  animation = new Animation
    render: render
    # 4 (move block, update sensors, updated hidden, move animat)
    # * number of trials * 36
    numFrames: NUM_SUBFRAMES * json.trials.length * json.config.WORLD_HEIGHT - 1
    speed: 8
    speedMultiplier: 2
    timestepFormatter: (timestep) -> "Trial #{getTrialNum()}"
    timestepSliderStep: NUM_SUBFRAMES * gameLength

  animation.play()
