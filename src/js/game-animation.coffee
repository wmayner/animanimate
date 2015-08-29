###
# game-animation.coffee
###

# Initialize interface components
network = require './network'
Animation = require './animation'
environment = require './environment'

NUM_SUBFRAMES = 3

FF_NAMES =
  mat: 'Matching (average 𝚽 weighted)'
  bp: '𝚽'
  sp: '∑ 𝛗'
  sp_wvn: '∑ 𝛗 (world vs. noise)'
  ex: 'Extrinsic cause information'
  ex_wvn: 'Extrinsic cause information (world vs. noise)'
  mi: 'Mutual information'
  mi_wvn: 'Mutual information (world vs. noise)'

gameInfoElt =
titleElt =

renderGameInfo = (json) ->
  # Update title.
  $('#title').text(FF_NAMES[json.config.FITNESS_FUNCTION])
  $('#seed').text(json.config.SEED)
  $('#generation').text(json.generation)
  $('#correct-trials').text(json.correct)
  $('#incorrect-trials').text(json.incorrect + json.correct)
  $('#notes').text(json.notes)
  $('#fitness').text(json.fitness.toFixed(4))

exports.init = (network, json) ->
  console.log json

  # Display game configuration.
  renderGameInfo(json)

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

  renderPhiData = (gameState) ->
    d = gameState.phidata
    $('#num-concepts').text(d.length)
    # newText = (
    #   "<div class='concept'>
    #   <div class='concept-part'>𝛗: <strong>#{c.phi}</strong></div>
    #   <div class='concept-part'>M: <strong>#{c.mechanism}</strong></div>
    #   <div class='concept-part'>P: <strong>#{c.purview}</strong></div>
    #   </div>" for c in d).join(' ')
    newText = (
      "<div class='concept'>
      <div class='concept-part'>𝛗: <strong>#{c.phi}</strong></div>
      <div class='concept-part'>M: <strong>#{c.mechanism}</strong></div>
      <div class='concept-part'>CP: <strong>#{c.cause.purview}</strong></div>
      <div class='concept-part'>EP: <strong>#{c.effect.purview}</strong></div>
      </div>" for c in d).join(' ')
    $('#concept-list').html(newText)

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
    renderPhiData(gameState)
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
