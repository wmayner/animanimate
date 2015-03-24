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


# Helpers
# =====================================================================

# TODO use classes and CSS instead. Somehow that's broken... when blocks wrap
# they acquire the '.animat' class magically. Game needs serious
# refactoring/fixing.

# Color boxes based on role in the animat.
blockColor = (block) ->
  if block.isAnimat
    return colors.animat
  else
    return colors.block

# =====================================================================


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

  # Update the block list.
  blocks = game.getBlocks().concat(game.getAnimat())

  # Bind newly-fetched boxes to rects selection.
  rects = rects.data blocks

  # Add new blocks.
  rects.enter()
    .append 'svg:rect'
      .attr 'class', 'block'
      .attr 'width', (block) ->
        block.width * GRID_WIDTH
      .attr 'height', GRID_HEIGHT

  # Update existing blocks.
  # Note: since we appended to the enter selection, this will be applied to the
  # new rect elements we just created.
  rects
      .attr 'width', (block) -> block.width * GRID_WIDTH
      .attr 'x', (block) -> block.position.x * GRID_WIDTH
      .attr 'y', (block) -> block.position.y * GRID_HEIGHT
      .style 'fill', blockColor
      .style 'opacity', (block) ->
        if block.on then 0.2 else 1

  # Remove old boxes.
  rects.exit().remove()
# =====================================================================


exports.load = (newGame) ->
  game = newGame
  update()

exports.updateBlocks = ->
  game.updateBlocks()
  update()

exports.updateAnimat = ->
  game.updateAnimat()
  update()
