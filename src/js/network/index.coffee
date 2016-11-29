###
# network/index.coffee
###

utils = require '../utils'
Graph = require './graph'
colors = require '../colors'

# This determines behavior that differs between evolution and game display.
exports.CONFIG = undefined
# Remember to set this once you have loaded the json data.
exports.nodeTypes = undefined

CONTAINER_SELECTOR = '#network-container'

$container = $(CONTAINER_SELECTOR)
height = 616
width = 528

MAXIMUM_NODES = 5
NODE_RADIUS = 25


# Helpers
# =============================================================================

# Get node positions.
getPositions = (config) ->
  positions = utils.dict([i, {fixed: true}] for i in [0...config.NUM_NODES])
  padding = 40
  xscale = d3.scale.linear()
  xRange = [padding, width - padding]
  xscale.range(xRange)
  # Sensors and motors.
  xscale.domain([d3.min(config.SENSOR_INDICES) - 1,
                 d3.max(config.SENSOR_INDICES) + 1])
  for i in config.SENSOR_INDICES
    positions[i].x = xscale(i)
    positions[i].y = padding
  xscale.domain([d3.min(config.MOTOR_INDICES) - 1,
                 d3.max(config.MOTOR_INDICES) + 1])
  for i in config.MOTOR_INDICES
    positions[i].x = xscale(i)
    positions[i].y = height - padding
  # Make rows of 2 hidden units each. If the number of hidden units is odd, the
  # first row will have only one.
  numHidden = config.HIDDEN_INDICES.length
  oddHidden = numHidden % 2
  numRows = Math.ceil(numHidden / 2)
  yscale = d3.scale.linear()
  yscale.range([padding, height - padding])
  yscale.domain([-1, numRows])
  hidden_x = [padding, width - padding]
  for hidden in config.HIDDEN_INDICES
    i = hidden - config.NUM_SENSORS
    positions[hidden].x = xRange[i % 2]
    row = Math.floor(i / 2)
    positions[hidden].y = yscale(row)
  return positions

# Alphabet for letter labels of nodes.
ALPHABET = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
            'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

getLabel = (index) -> utils.getLabel(index, exports.nodeTypes)

# Color nodes based on role in the animat.
nodeColor = (node) ->
  if graph.getAllEdgesOf(node._id).length is 0
    return colors.node.other
  if node.index in exports.nodeTypes.sensors
    return colors.node.sensor
  else if node.index in exports.nodeTypes.hidden
    return colors.node.hidden
  else if node.index in exports.nodeTypes.motors
    return colors.node.motor
  else
    return colors.node.other

getMechanismTableHeader = (inputs, label) ->
  return """
      <thead>
        <tr>
          #{('<th>' + getLabel(i) + '</th>' for i in inputs[...-1]).join('')}
          <th class='last-input'>#{getLabel(inputs[inputs.length - 1])}</th>
          <th></th>
          <th class="current-state">#{label}</th>
        </tr>
      </thead>
  """

getMechanismTableRows = (partial_tpm, classes = []) ->
  return (
    "<tr class='#{(c for c in classes).join(' ')}'>" +

    # All inputs except the last
    ('<td>' + i + '</td>' for i in row[0][...-1]).join('') +
    # The last input
    '<td class="last-input">' + row[0][row[0].length - 1] + '</td>' +
    '<td class="mapping-arrow">→</td>' +
    # The current state
    '<td class="current-state' + '">' + row[1] + '</td>' +

    '</tr>' for row in partial_tpm).join('')

# Display a node's mechanism in a tooltip.
tip = d3.tip()
  .attr('class', 'd3-tip')
  .offset([-10, 0])
  .html (d) ->
    return 'No inputs' if d.mechanism.inputs.length is 0
    return [
      '<table class="table table-condensed mechanism-table">'
      getMechanismTableHeader(d.mechanism.inputs, d.label)
      '<tbody>'
      getMechanismTableRows(d.mechanism.tpm[0], ['off-row'])
      getMechanismTableRows(d.mechanism.tpm[1], ['on-row'])
      '<tbody></table>'
    ].join('')
# =============================================================================

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


# Activate the tooltip module.
svg.call(tip)
# Globals that keep track of which node the mechanism tooltip is on.
mostRecentlyClickedNode = false
tippedNode = null
# Remove tooltips when clicking outside a node.
svg.on 'mousedown', ->
  tip.hide(tippedNode)
  mostRecentlyClickedNode = false
  tippedNode = null


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
        # Enlarge target node
        d3.select(this).attr 'transform', 'scale(1.1)'
      .on 'mouseout', (node) ->
        # Unenlarge target node
        d3.select(this).attr 'transform', ''
      .on 'mousedown', (node) ->
        d3.event.stopPropagation()
        mostRecentlyClickedNode = node
        if mostRecentlyClickedNode is tippedNode
          tip.hide(tippedNode)
          tippedNode = null
        else
          tip.hide(tippedNode)
          tip.show(mostRecentlyClickedNode)
          tippedNode = node

  # Show node IDs.
  g.append 'svg:text'
      .attr 'x', 0
      .attr 'y', 7
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
      .style 'fill', nodeColor
      # Make node more transparent if it is off.
      .style 'fill-opacity', (node) ->
        if exports.CONFIG is 'EVOLUTION'
          return 1
        else if exports.CONFIG is 'GAME'
          return (if node.on then 1 else 0.3)
      .classed 'reflexive', (node) ->
        node.reflexive
  # Update displayed mechanisms and IDs.
  circleGroup.select '.node-label.id'
    .text (node) -> node.label
    .style 'font-weight', (node) ->
      if exports.CONFIG is 'EVOLUTION'
        return 'normal'
      else if exports.CONFIG is 'GAME'
        return (if node.justSet then 'bold' else 'normal')


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

exports.WIDTH = width

exports.load = (newGraph) ->
  graph = newGraph
  update()


exports.graphFromJson = (json, config) ->
  positions = getPositions(config)
  graph = new Graph()
  for i in [0...json.cm.length]
    node = graph.addNode(positions[i])
    node.label = getLabel(i)
    node.mechanism = json.mechanisms[i]
  for i in [0...json.cm.length]
    for j in [0...json.cm[i].length]
      if json.cm[i][j]
        graph.addEdge(i, j)
  return graph


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
