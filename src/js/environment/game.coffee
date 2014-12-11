###
# game.coffee
###

utils = require './utils'

class Block

  constructor: (@position, @width) ->

class Animat

  constructor: (@position) ->

class Game

  constructor: ->
    @_grid = [36,16]
    @_blocks = {}
    @_animat = new Animat({x: 35, y: 7})

  getNewBlockId: ->
    id = @_newBlockId
    @_newBlockId++
    return id

  addBlock: (position, width) ->
    ###
    _Returns:_ the block object. Feel free to attach additional custom properties
    on it for graph algorithms' needs. **Undefined if block id already exists**,
    as to avoid accidental overrides.
    ###
    block =
      _id: @getNewBlockId()
    @numBlocks++
    @_blocks[block._id] = block
    return block

  moveBlock: (direction) ->
    ###
    _Returns:_ the block object. Moved one step to the left or right, and one step down.
    ###
    if direction == 0
      block.position[1]++
    else
      block.position[1]--
    block.position[0]++
    return

  getBlock: (id) ->
    ###
    _Returns:_ the block object.
    ###
    @_blocks[id]

  getBlocks: ->
    ###
    _Returns:_ an array of all block objects.
    ###
    (@_blocks[id] for id in Object.keys(@_blocks))

  getBlockByIndex: (index) ->
    result = null
    @forEachBlock (block, id) ->
      if block.index is index
        result = block
    return result

  removeBlock: (id) ->
    ###
    _Returns:_ the block object removed, or undefined if it didn't exist in the
    first place.
    ###
    blockToRemove = @_blocks[id]
    if not blockToRemove then return
    @blockSize--
    delete @_blocks[id]
    return blockToRemove

  forEachBlock: (operation) ->
    ###
    Traverse through the graph in an arbitrary manner, visiting each block once.
    Pass a function of the form `fn(blockObject, blockId)`.

    _Returns:_ undefined.
    ###
    for own blockId, blockObject of @_blocks
      operation blockObject, blockId
    # Manually return. This is to avoid CoffeeScript's nature of returning an
    # expression, unneeded and wastful (array) in this case.
    return

  getBlocksByIndex: ->
    return (@getBlockByIndex(index) for index in [0...@blockSize])

  mapByIndex: (operation) ->
    return (operation(block) for block in @getBlocksByIndex())

  # Return the given property for each block, in order of block indices.
  getBlockProperties: (property, block_indices) ->
    if block_indices?
      return (block[property] for block in @getBlocksByIndex() when block.index in block_indices)
    else
      return (block[property] for block in @getBlocksByIndex())


module.exports = Game