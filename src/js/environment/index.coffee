###
# environment/index.coffee
###

Game = require './game'
colors = require '../colors'


CONTAINER_SELECTOR = '#environment-container'
$container = $(CONTAINER_SELECTOR)
height = 616
width = 528

ENVIRONMENT_WIDTH = 16
ENVIRONMENT_HEIGHT = 36

GRID_WIDTH = width / ENVIRONMENT_WIDTH
GRID_HEIGHT = height / ENVIRONMENT_HEIGHT

game = undefined

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
update = ->

  # Update the cell list
  rects = rects.data game.getCells()

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


exports.load = (newGame) ->
  game = newGame
  update()

exports.updateBlock = ->
  game.updateBlock()
  update()

exports.updateAnimat = ->
  game.updateAnimat()
  update()
