###
# network/index.coffee
###

Graph = require './graph'
colors = require '../colors'

MAXIMUM_NODES = 5
CONTAINER_SELECTOR = '#network-container'

$container = $(CONTAINER_SELECTOR)
height = 616
width = 528

ARROW_COLOR = d3.rgb 130, 130, 130

NODE_LABEL_COLOR = '#444'
NODE_RADIUS = 25


# Set up initial graph.
graph = new Graph()

nodes = graph.getNodes()
links = graph.getDrawableEdges()


# Helpers
# =================================================================

exports.SENSORS = [0, 1]
exports.HIDDEN = [2, 3, 4, 5]
exports.MOTORS = [6, 7]

SENSOR_COLOR = colors.node.sensor
HIDDEN_COLOR = colors.node.hidden
MOTOR_COLOR = colors.node.motor
OTHER_NODE_COLOR = colors.node.other

# Color nodes based on role in the animat.
nodeColor = (node) ->
  if node.index in exports.SENSORS
    return SENSOR_COLOR
  else if node.index in exports.HIDDEN
    return HIDDEN_COLOR
  else if node.index in exports.MOTORS
    return MOTOR_COLOR
  else
    return OTHER_NODE_COLOR

# =================================================================


end_arrow_fill_color = d3.rgb()
start_arrow_fill_color = ARROW_COLOR.darker()

svg = d3.select(CONTAINER_SELECTOR)
  .append('svg')
    .attr('width', width)
    .attr('height', height)
    .attr('align', 'center')

# define arrow markers for graph links
svg
  .append('svg:defs')
  .append('svg:marker')
    .attr('id', 'end-arrow')
    .attr('viewBox', '0 -5 10 10')
    .attr('refX', 6)
    .attr('markerWidth', 3)
    .attr('markerHeight', 4)
    .attr('orient', 'auto')
  .append('svg:path')
    .attr('d', 'M0,-5L10,0L0,5')
    .attr('fill', end_arrow_fill_color)
    .classed('arrow-head', true)

svg
  .append('svg:defs')
  .append('svg:marker')
    .attr('id', 'start-arrow')
    .attr('viewBox', '0 -5 10 10')
    .attr('refX', 4)
    .attr('markerWidth', 3)
    .attr('markerHeight', 4)
    .attr('orient', 'auto')
  .append('svg:path')
    .attr('d', 'M10,-5L0,0L10,5')
    .attr('fill', start_arrow_fill_color)
    .classed('arrow-head', true)

# line displayed when dragging new nodes
drag_line = svg
  .append('svg:path')
    .attr('class', 'link dragline hidden')
    .attr('d', 'M0,0L0,0')

# handles to link and node element groups
path = svg
  .append('svg:g')
    .selectAll('path')
circleGroup = svg
  .append('svg:g')
    .selectAll('g')

selected_node = null
selected_link = null
mousedown_link = null
mousedown_node = null
mouseup_node = null

# mouse event vars
resetMouseVars = ->
  mousedown_node = null
  mouseup_node = null
  mousedown_link = null
  return


# update force layout (called automatically each iteration)
tick = ->
  # draw directed edges with proper padding from node centers
  path.attr("d", (edge) ->
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
  )
  circleGroup.attr('transform', (node) ->
    "translate(#{node.x},#{node.y})"
  )
  return


# update graph (called when needed)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
restart = ->

  # Update the node and edge list
  nodes = graph.getNodes()
  links = graph.getDrawableEdges()


  # Bind newly-fetched links to path selection.
  path = path.data(links)
  # Update existing links.
  path
      .classed('selected', (edge) ->
        graph.isSameLink(edge.key, selected_link)
      ).style('marker-start', (edge) ->
        (if edge.bidirectional then 'url(#start-arrow)' else "")
      ).style('marker-end', (edge) ->
        'url(#end-arrow)'
      )
  # Add new links.
  path.enter()
    .append('svg:path')
      .attr('class', 'link')
      .classed('selected', (edge) ->
        edge.key is selected_link
      ).style('marker-start', (edge) ->
        (if edge.bidirectional then 'url(#start-arrow)' else '')
      ).style('marker-end', (edge) ->
        'url(#end-arrow)'
      ).on('mousedown', (edge) ->
        return if d3.event.shiftKey

        # select link
        mousedown_link = edge.key
        if mousedown_link is selected_link
          selected_link = null
        else
          selected_link = mousedown_link
        selected_node = null

        restart()
      )
  # Remove old links.
  path.exit().remove()

  # Bind newly-fetched nodes to circle selection.
  # NB: Nodes are known by the graph's internal ID, not by d3 index!
  circleGroup = circleGroup.data(nodes, (d) -> d._id)

  # Add new nodes.
  g = circleGroup.enter()
    .append('svg:g')

  g.append('svg:circle')
      .attr('class', 'node')
      .attr('r', NODE_RADIUS)
      .on('mouseover', (node) ->
        # enlarge target node
        d3.select(this).attr('transform', 'scale(1.1)')
      ).on('mouseout', (node) ->
        # unenlarge target node
        d3.select(this).attr('transform', '')
      ).on('mousedown', (node) ->
        return if d3.event.shiftKey

        # select/deselect node
        mousedown_node = node
        if mousedown_node is selected_node then selected_node = null
        else selected_node = mousedown_node
        selected_link = null

        restart()
      ).on('mouseup', (node) ->
        return if not mousedown_node

        # unenlarge target node
        d3.select(this).attr('transform', '')

        edge = graph.addEdge(mousedown_node._id, mouseup_node._id)

        if not edge?
          edge = graph.getEdge(mousedown_node._id, mouseup_node._id)

        # select new link
        selected_link = edge.key
        selected_node = null

        restart()
      )
  # Show node IDs.
  g.append('svg:text')
      .attr('x', 0)
      .attr('y', 8)
      .classed('node-label', true)
      .classed('id', true)
      .attr('fill', NODE_LABEL_COLOR)

  # Bind the data to the actual circle elements.
  circles = circleGroup.selectAll('circle').data(nodes, (node) -> node._id)

  # Update existing nodes.
  # Note: since we appended to the enter selection, this will be applied to the
  # new circle elements we just created.
  circles
      .style('fill', (node) -> nodeColor(node))
      # Lighten node if it has no connections.
      .style('opacity', (node) ->
        if graph.getAllEdgesOf(node._id).length is 0 then 0.4 else 1
      )
      .classed('reflexive', (node) ->
        node.reflexive
      )
  # Update displayed mechanisms and IDs.
  circleGroup.select('.node-label.id').text((node) -> node.label)

  # Remove old nodes.
  circleGroup.exit().remove()

  # Rebind the nodes and links to the force layout.
  force
    .nodes(nodes)
    .links(links)

  # Set the graph in motion.
  force.start()

# end of restart()
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mousemove = ->
  return unless mousedown_node
  # update drag line
  drag_line.attr('d', "M#{mousedown_node.x},#{mousedown_node.y}L#{d3.mouse(this)[0]},#{d3.mouse(this)[1]}")
  restart()


mousedown = ->
  selected_node = null unless mousedown_node
  selected_link = null unless mousedown_link
  restart()


# only respond once per keydown
lastKeyDown = -1


keydown = ->

  switch d3.event.keyCode
    # left arrow
    when 37
      selectPreviousNode()
      restart()
      break
    # up arrow
    when 38
      selectPreviousNode()
      restart()
      break
    # right arrow
    when 39
      selectNextNode()
      restart()
      break
    # down arrow
    when 40
      selectNextNode()
      restart()
      break

  return unless lastKeyDown is -1
  lastKeyDown = d3.event.keyCode

  # shift
  if d3.event.keyCode is 16
    circleGroup.call(force.drag)
    svg.classed('shiftkey', true)

  return if not selected_node and not selected_link

  # Node or link is selected:
  # Grab selected link source and target ids.
  if selected_link
    ids = selected_link.split(',')
    sourceId = ids[0]
    targetId = ids[1]
  switch d3.event.keyCode
    # backspace, delete
    when 8, 46
      d3.event.preventDefault()
      if selected_node
        removed = graph.removeNode(selected_node._id)
        selected_node = null
        restart()
      else if selected_link
        graph.removeEdge(sourceId, targetId)
        graph.removeEdge(targetId, sourceId)
        selected_link = null
        restart()
      break
    # d
    when 68
      if selected_link
        # Cycle through link directions:
        # Faithful selected_link -> switch
        if (graph.getEdge(sourceId, targetId) and
            not graph.getEdge(targetId, sourceId))
          graph.removeEdge(sourceId, targetId)
          graph.addEdge(targetId, sourceId)
        # Switched selected_link -> bidirectional
        else if (graph.getEdge(targetId, sourceId) and
                 not graph.getEdge(sourceId, targetId))
          graph.addEdge(sourceId, targetId)
        # Bidirectional -> faithful selected_link
        else if (graph.getEdge(sourceId, targetId) and
                 graph.getEdge(targetId, sourceId))
          graph.removeEdge(targetId, sourceId)
        restart()
      break
    # b
    when 66
      if selected_link
        graph.addEdge(sourceId, targetId)
        graph.addEdge(targetId, sourceId)
        restart()
      break
    # space
    when 32
      d3.event.preventDefault()
      if selected_node
        graph.toggleState(selected_node)
        restart()
      break
    # m
    when 77
      if selected_node
        graph.cycleMechanism(selected_node)
        restart()
      break
    # r
    when 82
      if selected_node
        graph.toggleReflexivity(selected_node)
        restart()
      break


selectNextNode = ->
  if not selected_node or selected_node.index is graph.nodeSize - 1
    selected_node = graph.getNodeByIndex(0)
  else
    selected_node = graph.getNodeByIndex(selected_node.index + 1)


selectPreviousNode = ->
  if not selected_node or selected_node.index is 0
    selected_node = graph.getNodeByIndex(graph.nodeSize - 1)
  else
    selected_node = graph.getNodeByIndex(selected_node.index - 1)


keyup = ->
  lastKeyDown = -1
  # shift
  if d3.event.keyCode is 16
    circleGroup
        .on('mousedown.drag', null)
        .on('touchstart.drag', null)
    svg.classed('shiftkey', false)


nearestNeighbor = (node, nodes) ->
  nearest = selected_node
  minDistance = Infinity
  for n in nodes
    d = dist([node.x, node.y], [n.x, n.y])
    if d <= minDistance
      minDistance = d
      nearest = n
  return nearest


dist = (p0, p1) ->
  Math.sqrt(Math.pow(p1[0] - p0[0], 2) + Math.pow(p1[1] - p0[1], 2))


# init D3 force layout
force = d3.layout.force()
    .nodes(nodes)
    .links(links)
    .size([width, height])
    .linkDistance(175)
    .linkStrength(0.75)
    .charge(-900)
    .on('tick', tick)

# app starts here

# svg
#     .on('dblclick', dblclick)
#     .on('mousemove', mousemove)
#     .on('mousedown', mousedown)
#     .on('mouseup', mouseup)

# d3.select(document)
#     .on('keyup', keyup)

restart()

exports.load = (newGraph) ->
  graph = newGraph
  restart()

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
