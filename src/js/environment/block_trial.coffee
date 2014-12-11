###
# blocks.coffee
###

utils = require './utils'

###
Graph implemented as a modified incidence list. O(1) for every typical
operation except `removeBox()` at O(E) where E is the number of edges.

## Overview example:

```js
var graph = new Graph;
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
    @_boxes = {}
    @boxSize = 0
    @_newBoxId = 0

  getNewBoxId: ->
    id = @_newBoxId
    @_newBoxId++
    return id

  addBox: (boxData = {}) ->
    ###
    _Returns:_ the box object. Feel free to attach additional custom properties
    on it for graph algorithms' needs. **Undefined if box id already exists**,
    as to avoid accidental overrides.
    ###
    box =
      _id: @getNewBoxId()
      index: @boxSize
    for key, value of boxData
      box[key] = value
    @boxSize++
    @_boxes[box._id] = box
    return box

  getBox: (id) ->
    ###
    _Returns:_ the box object.
    ###
    @_boxes[id]

  getBoxes: ->
    ###
    _Returns:_ an array of all box objects.
    ###
    (@_boxes[id] for id in Object.keys(@_boxes))

  getBoxByIndex: (index) ->
    result = null
    @forEachBox (box, id) ->
      if box.index is index
        result = box
    return result

  removeBox: (id) ->
    ###
    _Returns:_ the box object removed, or undefined if it didn't exist in the
    first place.
    ###
    boxToRemove = @_boxes[id]
    if not boxToRemove then return
    else
      @boxSize--
      delete @_boxes[id]
    # Reassign indices/labels so they're always consecutive integers/letters.
    @forEachBox (box) ->
      if box.index > boxToRemove.index
        box.index--
    return boxToRemove

  forEachBox: (operation) ->
    ###
    Traverse through the graph in an arbitrary manner, visiting each node once.
    Pass a function of the form `fn(boxObject, boxId)`.

    _Returns:_ undefined.
    ###
    for own boxId, boxObject of @_boxes
      operation boxObject, boxId
    # Manually return. This is to avoid CoffeeScript's nature of returning an
    # expression, unneeded and wastful (array) in this case.
    return

  getBoxsByIndex: ->
    return (@getBoxesByIndex(index) for index in [0...@boxSize])

  mapByIndex: (operation) ->
    return (operation(box) for box in @getBoxesByIndex())

  reverseKey: (key) ->
    if not key?
      return null
    ids = key.split(',')
    return ids[1] + ',' + ids[0]

  # Return the given property for each box, in order of box indices.
  getBoxProperties: (property, box_indices) ->
    if box_indices?
      return (box[property] for box in @getBoxesByIndex() when box.index in box_indices)
    else
      return (box[property] for box in @getBoxesByIndex())

  toggleState: (box) ->
    box.on = utils.negate(box.on)  

module.exports = Block
