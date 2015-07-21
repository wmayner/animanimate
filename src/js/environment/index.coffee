###
# environment/index.coffee
###

colors = require '../colors'
utils = require '../utils'


CONTAINER_SELECTOR = '#environment-container'
$container = $(CONTAINER_SELECTOR)
height = 616
width = 528


wrap = (x) -> (config.WORLD_WIDTH + x) % config.WORLD_WIDTH

overlap = (frame) ->
  return frame.num is config.WORLD_HEIGHT - 1 and
    utils.any(frame.world[frame.pos + i] for i in [0...3])

cellBlockOverlap = (cell, frame) ->
  return frame.num is config.WORLD_HEIGHT - 1 and frame.world[cell.coords.x]

getCellsFromFrame = (frame) ->
  # Block cells
  block = ({
      coords: {x: i, y: frame.num},
      color: colors['block']
  } for i in [0...config.WORLD_WIDTH] when frame.world[i])
  # Animat cells
  animat = ({
    coords: {x: wrap(frame.pos + i), y: config.WORLD_HEIGHT - 1}
    color: colors['animat']['body']
  } for i in [0...3])
  for loc, i in config.SENSOR_LOCATIONS
    animat[loc].color = colors['animat']['sensor'][frame.animat[i]]
  for cell, i in animat
    if cellBlockOverlap(cell, frame)
      cell.color = colors['animat']['overlap']
  # Return all cells
  return block.concat(animat)


GRID_WIDTH = undefined
GRID_HEIGHT = undefined
config = undefined

# Declare the canvas.
svg = d3.select CONTAINER_SELECTOR
  .append 'svg'
    .attr 'width', width
    .attr 'height', height
    .attr 'align', 'center'

# Background.
background = svg.append 'rect'
  .attr 'width', '100%'
  .attr 'height', '100%'
  .attr 'fill', 'white'
  .attr 'opacity', 0

rects = svg
  .append 'svg:g'
    .selectAll 'rect'

# Update game (call when needed).
# =====================================================================
update = (trial, timestep) ->
  frame = trial.timesteps[timestep]

  # Update the cell list
  rects = rects.data getCellsFromFrame(frame)

  # Add new cells.
  rects.enter()
    .append 'svg:rect'
      .attr 'class', 'cell'
      .attr 'width', GRID_WIDTH
      .attr 'height', GRID_HEIGHT

  # Update existing cells.
  # Note: since we appended to the enter selection, this will be applied to the
  # new rect elements we just created.
  rects
      .attr 'x', (cell) -> cell.coords.x * GRID_WIDTH
      .attr 'y', (cell) -> cell.coords.y * GRID_HEIGHT
      .style 'fill', (cell) -> cell.color

  # Remove old cells.
  rects.exit().remove()

  isLastTimestep = (timestep == config.WORLD_HEIGHT - 1)
  background.attr 'fill', ->
    if isLastTimestep
      return if trial.correct then colors['success'] else colors['failure']
    else
      'white'
  background.attr 'opacity', -> if isLastTimestep then 0.3 else 0

# =====================================================================

exports.update = (trial, timestep) ->
  update(trial, timestep)

exports.loadConfig = (newConfig) ->
  config = newConfig
  GRID_WIDTH = width / config.WORLD_WIDTH
  GRID_HEIGHT = height / config.WORLD_HEIGHT
