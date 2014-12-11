###
# network/index.coffee
###

Block = require './game'
colors = require '../colors'


CONTAINER_SELECTOR = '#environment-container'
$container = $(CONTAINER_SELECTOR)
height = 616
width = 528

MAXIMUM_NODES = 5
NODE_RADIUS = 25

ENVIRONMENT_BLOCK_WIDTH = 16
ENVIRONMENT_BLOCK_HEIGHT = 36

BLOCK_WIDTH = width/ENVIRONMENT_BLOCK_WIDTH
BLOCK_HEIGHT = height/ENVIRONMENT_BLOCK_HEIGHT
BLOCK_COLOR = d3.rgb 100, 200, 0

# Helpers
# =====================================================================

# Color boxes based on role in the animat.
nodeColor = (node) ->
  if node.index in exports.SENSORS
    return colors.node.sensor
  else if node.index in exports.HIDDEN
    return colors.node.hidden
  else if node.index in exports.MOTORS
    return colors.node.motor
  else
    return colors.node.other

# =====================================================================

# Declare the canvas.
svg = d3.select CONTAINER_SELECTOR
  .append 'svg'
    .attr 'width', width
    .attr 'height', height
    .attr 'align', 'center'

rectGroup = svg
  .append 'svg:g'
    .selectAll 'g'


# Update force layout (called automatically each iteration).
tick = ->
  # # Draw directed edges with proper padding from node centers.
  # path.attr "d", (edge) ->
  #   deltaX = edge.target.x - edge.source.x
  #   deltaY = edge.target.y - edge.source.y
  #   dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY)
  #   normX = deltaX / dist
  #   normY = deltaY / dist
  #   sourcePadding = (if edge.bidirectional then NODE_RADIUS + 5 else NODE_RADIUS)
  #   targetPadding = NODE_RADIUS + 5
  #   sourceX = edge.source.x + (sourcePadding * normX)
  #   sourceY = edge.source.y + (sourcePadding * normY)
  #   targetX = edge.target.x - (targetPadding * normX)
  #   targetY = edge.target.y - (targetPadding * normY)
  #   return "M#{sourceX},#{sourceY}L#{targetX},#{targetY}"
  rectGroup.attr 'transform', (node) ->
    "translate(#{node.x},#{node.y})"
  return


# Update block (call when needed).
# =====================================================================
update = ->

  # Update the node and edge list.
  #boxes = block.getBoxes()

  # Bind newly-fetched boxes to rect selection.
  # NB: Boxes are known by the block's internal ID, not by d3 index!
  rectGroup = rectGroup.data blocks


  # Add new boxes.
  g = rectGroup.enter()
    .append 'svg:g'

  g.append 'svg:rect'
      .attr 'class', 'node'
      .attr 'width', BLOCK_WIDTH
      .attr 'height', BLOCK_HEIGHT
      .on 'mouseover', (node) ->
        # enlarge target node
        d3.select(this).attr 'transform', 'scale(1.1)'
      .on 'mouseout', (node) ->
        # unenlarge target node
        d3.select(this).attr 'transform', ''

  # Bind the data to the actual rect elements.
  rects = rectGroup.selectAll 'rect'
    .data boxes, (node) -> node._id

  # Update existing boxes.
  # Note: since we appended to the enter selection, this will be applied to the
  # new rect elements we just created.
  rects
      .attr 'x', (block) -> block.position[0]
      .attr 'y', (block) -> block.position[1]
      .style 'fill', (node) -> BLOCK_COLOR
      # Lighten node if it has no connections.
      .style 'opacity', (node) ->
        #if block.getAllEdgesOf(node._id).length is 0 then 0.4 else 1
        if node.on then 1 else 0.2
      .classed 'reflexive', (node) ->
        node.reflexive
  # Update displayed mechanisms and IDs.
  rectGroup.select '.node-label.id'
    .text (node) -> node.label

  # Remove old boxes.
  rectGroup.exit().remove()
# =====================================================================


# Set up initial block.
block = new Block()
boxes = block.getBlocks()
# Initialize D3 force layout.
blocks = [
  {
    position: [0,0]
  }
]
update()


exports.load = (newBlock) ->
  block = newBlock
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
