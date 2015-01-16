###
# animation.coffee
###

PLAY_PAUSE_BUTTON_SELECTOR = '#play-pause'
TIMESTEP_SLIDER_SELECTOR = '#timestep-slider-container > input.slider'
TIMESTEP_DISPLAY_SELECTOR = '#timestep'
SPEED_SLIDER_SELECTOR = '#speed-slider-container > input.slider'

togglePlaybackButton = $(PLAY_PAUSE_BUTTON_SELECTOR)
timestepSlider = $(TIMESTEP_SLIDER_SELECTOR)
timestepDisplay = $(TIMESTEP_DISPLAY_SELECTOR)
speedSlider = $(SPEED_SLIDER_SELECTOR)

displayPlayButton = ->
  togglePlaybackButton.find('span')
      .removeClass('glyphicon-pause')
      .addClass('glyphicon-play')
displayPauseButton = ->
  togglePlaybackButton.find('span')
      .removeClass('glyphicon-play')
      .addClass('glyphicon-pause')


class Animation
  constructor: (config) ->
    @render = config.render
    @lastFrame = (config.numFrames - 1)
    @timestepSliderStep = config.timestepSliderStep
    @onReset = config.reset or ->
    @timestepFormatter = config.timestepFormatter
    @speedMultiplier = config.speedMultiplier or 1

    @speed = 110
    @nextFrame = 0
    @timeout = 0
    @running = false
    @finished = false


    # Initialize sliders.
    speedSlider.slider(
      id: 'speed-slider'
      reversed: true
      min: 10
      max: 510
      step: 50
      value: @speed
      formatter: (value) ->
        scale = d3.scale.linear().domain([@min, @max]).range([10, 1])
        return "Speed: #{d3.round(scale(value), 0)}"
    )
    timestepSlider.slider(
      id: 'timestep-slider'
      min: 0
      max: @lastFrame
      step: @timestepSliderStep
      value: 0
      formatter: @timestepFormatter
    )

    # Event handlers.
    handlePlayButton = =>
      if @running
        @pause()
      else
        @play()
    handleSpeedSlider = (e) =>
      @speed = e.value
    handleTimestepSlider = (e) =>
      @pause()
      @setNextFrame(e.value)
      @render(@nextFrame)

    # Bind event handlers.
    togglePlaybackButton.mouseup handlePlayButton
    timestepSlider
      .on 'slide', handleTimestepSlider
      .on 'slideStop', handleTimestepSlider
      .data 'slider'
    speedSlider
      .on 'slide', handleSpeedSlider
      .on 'slideStop', handleSpeedSlider
      .data 'slider'

  setNextFrame: (newFrame) ->
    timestepSlider.slider('setValue', newFrame)
    timestepDisplay.html(@timestepFormatter newFrame)
    @nextFrame = newFrame
    if @nextFrame >= @lastFrame
      @finished = true
    else
      @finished = false
    return @nextFrame

  tick: ->
    @render(@nextFrame)
    @setNextFrame(@nextFrame + 1)

  animate: =>
    unless @finished
      @tick()
      @timeout = setTimeout(@animate, @speed * (1 / @speedMultiplier))
    else
      @pause()

  reset: ->
    @setNextFrame(0)
    @finished = false
    @onReset()

  play: ->
    if @finished
      @reset()
    @running = true
    displayPauseButton()
    @animate()

  pause: ->
    clearTimeout(@timeout)
    displayPlayButton()
    @running = false


module.exports = Animation
