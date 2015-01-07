###
# network/index.coffee
###

Graph = require './graph'
colors = require '../colors'


exports.SENSORS = [0, 1]
exports.HIDDEN = [2, 3, 4, 5]
exports.MOTORS = [6, 7]


CONTAINER_SELECTOR = '#network-container'

$container = $(CONTAINER_SELECTOR)
height = 616
width = 528

MAXIMUM_NODES = 5
NODE_RADIUS = 25


# Helpers
# =====================================================================

# Color nodes based on role in the animat.
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

# Define arrow markers for graph links.
svg
  .append 'svg:defs'
  .append 'svg:marker'
    .attr 'id', 'end-arrow'
    .attr 'viewBox', '0 -5 10 10'
    .attr 'refX', 6
    .attr 'markerWidth', 3
    .attr 'markerHeight', 4
    .attr 'orient', 'auto'
  .append 'svg:path'
    .attr 'd', 'M0,-5L10,0L0,5'
    .attr 'fill', colors.link.endpoint
    .classed 'arrow-head', true
svg
  .append 'svg:defs'
  .append 'svg:marker'
    .attr 'id', 'start-arrow'
    .attr 'viewBox', '0 -5 10 10'
    .attr 'refX', 4
    .attr 'markerWidth', 3
    .attr 'markerHeight', 4
    .attr 'orient', 'auto'
  .append 'svg:path'
    .attr 'd', 'M10,-5L0,0L10,5'
    .attr 'fill', colors.link.endpoint
    .classed 'arrow-head', true

# Handles to link and node element groups.
path = svg
  .append 'svg:g'
    .selectAll 'path'
circleGroup = svg
  .append 'svg:g'
    .selectAll 'g'


# Update force layout (called automatically each iteration).
tick = ->
  # Draw directed edges with proper padding from node centers.
  path.attr "d", (edge) ->
    deltaX = edge.target.x - edge.source.x
    deltaY = edge.target.y - edge.source.y
    dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY)
    normX = deltaX / dist
    normY = deltaY / dist
    sourcePadding = (if edge.bidirectional then NODE_RADIUS + 5 else NODE_RADIUS)
    targetPadding = NODE_RADIUS + 5
    sourceX = edge.source.x + (sourcePadding * normX)
    sourceY = edge.source.y + (sourcePadding * normY)
    targetX = edge.target.x - (targetPadding * normX)
    targetY = edge.target.y - (targetPadding * normY)
    return "M#{sourceX},#{sourceY}L#{targetX},#{targetY}"
  circleGroup.attr 'transform', (node) ->
    "translate(#{node.x},#{node.y})"
  return


# Update graph (call when needed).
# =====================================================================
update = ->

  # Update the node and edge list.
  nodes = graph.getNodes()
  links = graph.getDrawableEdges()


  # Bind newly-fetched links to path selection.
  path = path.data links
  # Update existing links.
  path
      .style 'marker-start', (edge) ->
        if edge.bidirectional then 'url(#start-arrow)' else ""
      .style 'marker-end', (edge) ->
        'url(#end-arrow)'
  # Add new links.
  path.enter()
    .append 'svg:path'
      .attr 'class', 'link'
      .style 'marker-start', (edge) ->
        (if edge.bidirectional then 'url(#start-arrow)' else '')
      .style 'marker-end', (edge) ->
        'url(#end-arrow)'
  # Remove old links.
  path.exit().remove()

  # Bind newly-fetched nodes to circle selection.
  # NB: Nodes are known by the graph's internal ID, not by d3 index!
  circleGroup = circleGroup.data nodes, (d) -> d._id

  # Add new nodes.
  g = circleGroup.enter()
    .append 'svg:g'

  g.append 'svg:circle'
      .attr 'class', 'node'
      .attr 'r', NODE_RADIUS
      .on 'mouseover', (node) ->
        # enlarge target node
        d3.select(this).attr 'transform', 'scale(1.1)'
      .on 'mouseout', (node) ->
        # unenlarge target node
        d3.select(this).attr 'transform', ''
  # Show node IDs.
  g.append 'svg:text'
      .attr 'x', 0
      .attr 'y', 8
      .classed 'node-label', true
      .classed 'id', true
      .attr 'fill', colors.node.label

  # Bind the data to the actual circle elements.
  circles = circleGroup.selectAll 'circle'
    .data nodes, (node) -> node._id

  # Update existing nodes.
  # Note: since we appended to the enter selection, this will be applied to the
  # new circle elements we just created.
  circles
      .style 'fill', (node) -> 
        #nodeColor(node)
        if graph.getAllEdgesOf(node._id).length is 0 then nodeColor(1) else nodeColor(node)
      # Lighten node if it has no connections.
      .style 'opacity', (node) ->
        #if graph.getAllEdgesOf(node._id).length is 0 then 0.4 else 1
        if node.on then 1 else 0.2
      .classed 'reflexive', (node) ->
        node.reflexive
  # Update displayed mechanisms and IDs.
  circleGroup.select '.node-label.id'
    .text (node) -> node.label
    .style 'font-weight', (node) -> 
        if node.justSet then 'bold' else 'normal'

  # Remove old nodes.
  circleGroup.exit().remove()

  # Rebind the nodes and links to the force layout.
  force
    .nodes nodes
    .links links

  # Set the graph in motion.
  force.start()

# =====================================================================


# Set up initial graph.
graph = new Graph()
nodes = graph.getNodes()
links = graph.getDrawableEdges()
# Initialize D3 force layout.
force = d3.layout.force()
    .nodes nodes
    .links links
    .size [width, height]
    .linkDistance 175
    .linkStrength 0.75
    .charge -900
    .on 'tick', tick
update()


exports.load = (newGraph) ->
  graph = newGraph
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
