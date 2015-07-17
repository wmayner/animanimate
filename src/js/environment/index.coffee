###
# environment/index.coffee
###

colors = require '../colors'


CONTAINER_SELECTOR = '#environment-container'
$container = $(CONTAINER_SELECTOR)
height = 616
width = 528


wrap = (x) -> (config.WORLD_WIDTH + x) % config.WORLD_WIDTH

getCellsFromFrame = (frame) ->
  # Block cells
  ({
      coords: {x: i, y: frame.num},
      type: 'block'
   } for i in [0...config.WORLD_WIDTH] when frame.world[i])
  # Animat cells
  .concat({
    coords: {x: wrap(frame.pos + i), y: config.WORLD_HEIGHT - 1}
    type: 'animat'
  } for i in [0...3])


GRID_WIDTH = undefined
GRID_HEIGHT = undefined
config = undefined

# Declare the canvas.
svg = d3.select CONTAINER_SELECTOR
  .append 'svg'
    .attr 'width', width
    .attr 'height', height
    .attr 'align', 'center'

rects = svg
  .append 'svg:g'
    .selectAll 'rect'

# Update game (call when needed).
# =====================================================================
update = (frame) ->

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
      .style 'fill', (cell) -> colors[cell.type]
      .style 'opacity', (cell) -> if cell.on then 0.2 else 1

  # Remove old cells.
  rects.exit().remove()
# =====================================================================

exports.update = (frame) ->
  update(frame)

exports.loadConfig = (newConfig) ->
  config = newConfig
  GRID_WIDTH = width / config.WORLD_WIDTH
  GRID_HEIGHT = height / config.WORLD_HEIGHT
