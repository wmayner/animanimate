###
# game-animation.coffee
###

# Initialize interface components
network = require './network'
Animation = require './animation'
environment = require './environment'

NUM_SUBFRAMES = 3

exports.init = (network, json) ->
  config = json.config
  trials = json.trials
  # Tell the environment the game parameters.
  environment.loadConfig(config)

  # The number of timesteps in a game should be equal to the height of the
  # environment.
  gameLength = config.WORLD_HEIGHT

  trialNum = 0

  getTrialNum = -> trialNum

  # Initialize network.
  animat = network.connectivityToGraph(json.cm, config)
  network.load(animat)

  selectiveSetState = (toSet, state) ->
    animat.forEachNode (node, id) ->
      if node.index in toSet
        animat.setState(node, state[node.index])
      else
        animat.resetNode(node)
    return

  # Animation functions.
  renderSensors = (frame) ->
    # Color Sensors according to on/off and reset other nodes.
    selectiveSetState(config.SENSOR_INDICES, frame.animat)
    # Update network display.
    network.load(animat)
    return

  renderHiddenAndMotors = (frame) ->
    # Color Sensors according to on/off and reset other nodes.
    selectiveSetState(config.HIDDEN_INDICES.concat(config.MOTOR_INDICES),
                      frame.animat)
    # Update the network display.
    network.load(animat)
    return

  render = (nextFrame) ->
    # Trial number.
    trialNum = nextFrame // (NUM_SUBFRAMES * gameLength)
    # Current trial.
    trial = trials[trialNum]
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
    numFrames: NUM_SUBFRAMES * trials.length * config.WORLD_HEIGHT - 1
    speed: 8
    speedMultiplier: 2
    timestepFormatter: (timestep) -> "Trial #{getTrialNum()}"
    timestepSliderStep: NUM_SUBFRAMES * gameLength

  animation.play()
