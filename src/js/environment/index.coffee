###
# environment/index.coffee
###

Game = require './game'
colors = require '../colors'


CONTAINER_SELECTOR = '#environment-container'
$container = $(CONTAINER_SELECTOR)
height = 616
width = 528

MAXIMUM_NODES = 5
NODE_RADIUS = 25

ENVIRONMENT_WIDTH = 16
ENVIRONMENT_HEIGHT = 36

GRID_WIDTH = width/ENVIRONMENT_WIDTH
GRID_HEIGHT = height/ENVIRONMENT_HEIGHT
ANIMAT_COLOR = d3.rgb 200, 200, 0
BLOCK_COLOR = d3.rgb 100, 100, 0


game = undefined


# Helpers
# =====================================================================

# Color boxes based on role in the animat.
blockColor = (block) ->
  if block.isAnimat
    return ANIMAT_COLOR
  else
    return BLOCK_COLOR


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
      .on 'mouseover', (block) ->
        # Enlarge target block
        d3.select(this).attr 'transform', 'scale(1.1)'
      .on 'mouseout', (block) ->
        # Unenlarge target block
        d3.select(this).attr 'transform', ''

  # Update existing blocks.
  # Note: since we appended to the enter selection, this will be applied to the
  # new rect elements we just created.
  rects
      .attr 'width', (block) -> block.width * GRID_WIDTH
      .attr 'x', (block) -> block.position.x * GRID_WIDTH
      .attr 'y', (block) -> block.position.y * GRID_HEIGHT
      .style 'fill', blockColor
      # Lighten node if it has no connections.
      .style 'opacity', (block) ->
        #if block.getAllEdgesOf(node._id).length is 0 then 0.4 else 1
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