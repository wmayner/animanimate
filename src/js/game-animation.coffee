###
# game-animation.coffee
###

# Initialize interface components
utils = require './utils'
Animation = require './animation'
environment = require './environment'

NUM_SUBFRAMES = 3

FF_NAMES =
  nat: 'Correct Trials'
  mi: 'Mutual information'
  mi_wvn: 'Mutual information (world vs. noise)'
  ex: 'Extrinsic cause information'
  ex_wvn: 'Extrinsic cause information (world vs. noise)'
  sp: '∑ 𝛗'
  sp_wvn: '∑ 𝛗 (world vs. noise)'
  bp: '𝚽'
  bp_wvn: '𝚽 (world vs. noise)'
  sd_wvn: 'State differentiation (world vs. noise)'
  mat: 'Matching (average 𝚽 weighted)'
  food: 'Food'


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

  # Generate animat graph.
  animat = network.graphFromJson(json)

  # Initialize network.
  network.load(animat)

  selectiveSetState = (toSet, state) ->
    animat.forEachNode (node, id) ->
      if node.index in toSet
        animat.setState(node, state[node.index])
      else
        animat.resetNode(node)
    return

  indicesToLabels = (indices) ->
      (network.getLabel(index) for index in indices).join(', ')

  getConceptRow = (concept) ->
    return """<tr>
      <td class="mechanism">#{indicesToLabels(concept.mechanism)}</td>
      <td>#{concept.phi}</td>
      <td>#{indicesToLabels(concept.cause.purview)}</td>
      <td>#{concept.cause.phi}</td>
      <td>#{indicesToLabels(concept.effect.purview)}</td>
      <td>#{concept.effect.phi}</td>
    </tr>
    """

  getConceptTableBody = (constellation) ->
    return """<tbody>
    #{(getConceptRow(concept) for concept in constellation).join('')}
    </tbody>"""

  getConceptTable = (phidata) ->
    return """
    <table id='concept-table' class='table table-striped table-hover table-bordered'>
      <thead>
        <tr>
          <td rowspan='2' class="large">Mechanism</td>
          <td rowspan='2' class="large">𝛗</td>
          <td colspan='2'>Cause</td>
          <td colspan='2'>Effect</td>
        <tr>
          <td class="subheading">Purview</td>
          <td class="subheading">𝛗<sub><em>cause</em></sub></td>
          <td class="subheading">Purview</td>
          <td class="subheading">𝛗<sub><em>effect</em></sub></td>
      </thead>
      <tbody>
      #{getConceptTableBody(phidata.unpartitioned_constellation)}
      <tbody>
    </table>
    """

  renderPhiData = (gameState) ->
    d = gameState.phidata
    $('#num-concepts').text(d.unpartitioned_constellation.length)
    $('#concept-list').html(getConceptTable(d))

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
