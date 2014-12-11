###
# environment/index.coffee
###

Blocks = require './game'

CONTAINER_SELECTOR = '#environment-container'
ENVIRONMENT_BLOCK_WIDTH = 16
ENVIRONMENT_BLOCK_HEIGHT = 36

$container = $(CONTAINER_SELECTOR)
height = 616
width = 528

BOX_WIDTH = width/ENVIRONMENT_BLOCK_WIDTH
BOX_HEIGHT = height/ENVIRONMENT_BLOCK_HEIGHT
BOX_COLOR = d3.rgb 100, 200, 0

# Helpers
# =================================================================


# =================================================================
# Declare the canvas.
svg = d3.select(CONTAINER_SELECTOR)
  .append('svg')
    .attr('width', width)
    .attr('height', height)
    .attr('align', 'center')

# Handles to box element groups
squareGroup = svg
  .append('svg:g')
    .selectAll('g')


# Update force layout (called automatically each iteration)
tick = ->
  # draw directed edges with proper padding from node centers
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
  squareGroup.attr 'transform', (box) ->
    "translate(#{box.x},#{box.y})"
  return


# Update graph (call when needed).
# =====================================================================
update = ->

  # Update the box list
  boxes = blocks.getBoxes()

  # square (box) group
  # NB: the function arg is crucial here! nodes are known by id, not by index!
  square = square.data(boxes, (d) ->
    return d._id
  )

  # update existing boxes (reflexive & selected visual states)
  square.selectAll('square')
      .style('fill', (box) -> boxColor(box)
      ).classed('reflexive', (node) ->
        node.reflexive
      )

  # Bind newly-fetched boxes to square selection.
  # NB: Boxes are known by the blocks's internal ID, not by d3 index!
  squareGroup = squareGroup.data boxes, (d) -> d._id

  # Add new boxes.
  g = squareGroup.enter()
    .append 'svg:g'

  g.append 'svg:square'
      .attr 'class', 'box'
      .attr 'x', 0
      .attr 'y', 8
      .attr 'width', BOX_WIDTH
      .attr 'height', BOX_HEIGHT
      .on 'mouseover', (node) ->
        # enlarge target node
        d3.select(this).attr 'transform', 'scale(1.1)'
      .on 'mouseout', (node) ->
        # unenlarge target node
        d3.select(this).attr 'transform', ''
  
  # Bind the data to the actual circle elements.
  squares = squareGroup.selectAll 'square'
    .data boxes, (box) -> box._id

  # Update existing boxes.
  # Note: since we appended to the enter selection, this will be applied to the
  # new square elements we just created.
  squares
      .attr 'fill', BOX_COLOR
      #.style 'fill', (node) -> 
        #nodeColor(node)
        #if graph.getAllEdgesOf(node._id).length is 0 then nodeColor(1) else nodeColor(node)
      # Lighten node if it has no connections.
      .style 'opacity', (box) ->
        #if graph.getAllEdgesOf(node._id).length is 0 then 0.4 else 1
        if box.on then 1 else 0.2
  # Remove old nodes.
  squareGroup.exit().remove()

  # Rebind the nodes and links to the force layout.
  force
    .boxes boxes
    
  # Set the graph in motion.
  force.start()
# =====================================================================


# Set up initial graph.
blocks = new Blocks()
boxes = blocks.getBoxes()
# Initialize D3 force layout.
# force = d3.layout.force()
#     .boxes boxes
#     .size [width, height]
#     .charge -900
#     .on 'tick', tick
update()


exports.load = (newBlocks) ->
  blocks = newBlocks
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
