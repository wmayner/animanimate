###
# game.coffee
###

utils = require './utils'

###
Block implemented as a modified incidence list. O(1) for every typical
operation except `removeBox()` at O(E) where E is the number of edges.

## Overview example:

```js
var graph = new Block;
graph.addBox('A'); // => a node object. For more info, log the output or check
                    // the documentation for addBox
graph.addBox('B');
graph.addBox('C');
graph.addEdge('A', 'C'); // => an edge object
graph.addEdge('A', 'B');
graph.getEdge('B', 'A'); // => undefined. Directed edge!
graph.getEdge('A', 'B'); // => the edge object previously added
graph.getEdge('A', 'B').weight = 2 // weight is the only built-in handy property
                                   // of an edge object. Feel free to attach
                                   // other properties
graph.getInEdgesOf('B'); // => array of edge objects, in this case only one;
                         // connecting A to B
graph.getOutEdgesOf('A'); // => array of edge objects, one to B and one to C
graph.getAllEdgesOf('A'); // => all the in and out edges. Edge directed toward
                          // the node itself are only counted once
forEachBox(function(nodeObject) {
  console.log(node);
});
forEachEdge(function(edgeObject) {
  console.log(edgeObject);
});
graph.removeBox('C'); // => 'C'. The edge between A and C also removed
graph.removeEdge('A', 'B'); // => the edge object removed
```

## Properties:

- nodeSize: total number of nodes.
- edgeSize: total number of edges.
###

class Block

  constructor: ->
    @_nodes = {}
    @nodeSize = 0
    @edgeSize = 0
    @_newBoxId = 0

  getNewBoxId: ->
    id = @_newBoxId
    @_newBoxId++
    return id

  addBox: (nodeData = {}) ->
    ###
    _Returns:_ the node object. Feel free to attach additional custom properties
    on it for graph algorithms' needs. **Undefined if node id already exists**,
    as to avoid accidental overrides.
    ###
    node =
      _id: @getNewBoxId()
      _outEdges: {}
      _inEdges: {}
      index: @nodeSize
      label: ALPHABET[@nodeSize]
      on: 0
      mechanism: 'MAJ'
      reflexive: false
    for key, value of nodeData
      node[key] = value
    @nodeSize++
    @_nodes[node._id] = node
    return node

  getBox: (id) ->
    ###
    _Returns:_ the node object.
    ###
    @_nodes[id]

  getBoxes: ->
    ###
    _Returns:_ an array of all node objects.
    ###
    (@_nodes[id] for id in Object.keys(@_nodes))

  getBoxByIndex: (index) ->
    result = null
    @forEachBox (node, id) ->
      if node.index is index
        result = node
    return result

  removeBox: (id) ->
    ###
    _Returns:_ the node object removed, or undefined if it didn't exist in the
    first place.
    ###
    nodeToRemove = @_nodes[id]
    if not nodeToRemove then return
    else
      for own outEdgeId of nodeToRemove._outEdges
        @removeEdge id, outEdgeId
      for own inEdgeId of nodeToRemove._inEdges
        @removeEdge inEdgeId, id
      @nodeSize--
      delete @_nodes[id]
    # Reassign indices/labels so they're always consecutive integers/letters.
    @forEachBox (node) ->
      if node.index > nodeToRemove.index
        node.index--
        node.label = ALPHABET[node.index]
    return nodeToRemove

  forEachBox: (operation) ->
    ###
    Traverse through the graph in an arbitrary manner, visiting each node once.
    Pass a function of the form `fn(nodeObject, nodeId)`.

    _Returns:_ undefined.
    ###
    for own nodeId, nodeObject of @_nodes
      operation nodeObject, nodeId
    # Manually return. This is to avoid CoffeeScript's nature of returning an
    # expression, unneeded and wastful (array) in this case.
    return

  getBoxesByIndex: ->
    return (@getBoxByIndex(index) for index in [0...@nodeSize])

  mapByIndex: (operation) ->
    return (operation(node) for node in @getBoxesByIndex())

  reverseKey: (key) ->
    if not key?
      return null
    ids = key.split(',')
    return ids[1] + ',' + ids[0]

  # Return the given property for each node, in order of node indices.
  getBoxProperties: (property, node_indices) ->
    if node_indices?
      return (node[property] for node in @getBoxesByIndex() when node.index in node_indices)
    else
      return (node[property] for node in @getBoxesByIndex())

  toggleState: (node) ->
    node.on = utils.negate(node.on)

  setState: (node, state) ->
    node.on = utils.bit(state)

module.exports = Block
