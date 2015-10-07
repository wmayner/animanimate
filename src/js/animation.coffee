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


MIN_DELAY = 10
MAX_DELAY = 510
DELAY_STEP = 50

MIN_SPEED = 1
MAX_SPEED = 10

# Converts a speed, from 1 to 10, to a delay in milliseconds.
speedToDelay = (speed) -> MIN_DELAY + DELAY_STEP * (MAX_SPEED - speed)


class Animation
  constructor: (config) ->
    @render = config.render
    @lastFrame = (config.numFrames - 1)
    @timestepSliderStep = config.timestepSliderStep
    @onReset = config.reset or ->
    @timestepFormatter = config.timestepFormatter
    @speed = config.speed or 8
    @speedMultiplier = config.speedMultiplier or 1
    #@nextFrame = config.startFrame+1 or 0 # this is the frame the slider starts at
    @timeout = 0
    @running = false
    @finished = false

    # Initialize sliders.
    speedSlider.slider(
      id: 'speed-slider'
      min: MIN_SPEED
      max: MAX_SPEED
      step: 1
      value: @speed
      formatter: (value) -> "Speed: #{value}"
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
    @setNextFrame(@nextFrame)
    @nextFrame += 1
    
  animate: =>
    unless @finished
      @tick()
      @timeout = setTimeout(@animate, speedToDelay(@speed) * (1 / @speedMultiplier))
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
