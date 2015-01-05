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
  console.log blocks

  # Bind newly-fetched boxes to rects selection.
  rects = rects.data blocks

  # Add new blocks.
  rects.enter()
    .append 'svg:rect'
      .attr 'class', 'block'
      .attr 'width', (block) -> 
        console.log block._id
        console.log block.width
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


# Set up initial game.
# game = new Game()
# update()


exports.load = (newGame) ->
  game = newGame
  update()

exports.update = ->
  game.update()
  update()


# Copyright (c) 2013-2014 Ross Kirsling

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
