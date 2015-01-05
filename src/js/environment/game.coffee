###
# game.coffee
###

utils = require './utils'

class Block

  constructor: (@position, @width, @_id) ->
    @isWrapperBlock = false

class Animat

  constructor: (@position) ->
    @isAnimat = true
    @width = 3

class Game

  constructor: (@trial, @blockSize) -> 
    @_newBlockId = 0
    @_dimensions = [36,16]
    @_direction = (if ((@trial.trialNum - 1) // @_dimensions[1]) % 2 then 'right' else 'left')
    @_timeCounter = 0
    @_blocks = {}
    #Fix this. Animat should be at position 15 on trial 36
    @_animat = new Animat({x: (@trial.trialNum-1) % @_dimensions[1], y: 35})
    console.log @trial.trialNum
    width = @blockSize
    @addBlock({x: 0, y: 0}, width)

  getDimensions: -> @_dimensions

  getAnimat: -> @_animat

  getNewBlockId: ->
    id = @_newBlockId
    @_newBlockId++
    return id

  addBlock: (position, width, wrapperBlock) ->
    ###
    _Returns:_ the block object.
    ###
    block = new Block(position, width, @getNewBlockId())
    @numBlocks++
    @_blocks[block._id] = block
    if wrapperBlock
      block.isWrapperBlock = true
    return block

  update: ->
    for id, block of @_blocks
      if block.isWrapperBlock
        @removeBlock(block._id)
      else
        @moveBlock block, 'down'
        @moveBlock block, @_direction
      
    @moveAnimat @_animat
    @_timeCounter++

  calcAnimatDirection: ->
    motorStates = @trial.lifeTable[@_timeCounter][-2...]
    directionNum = (motorStates[0] + 2 * motorStates[1]) % 4
    switch directionNum
      when 1
        direction = 'right'
      when 2
        direction = 'left'
      else
        direction = 'none'
    return direction

  checkXPosition: (block) ->
    xPosition = block.position.x
    if xPosition >= @_dimensions[1]
      xPosition = xPosition % @_dimensions[1]
    else if xPosition < 0
       xPosition = @_dimensions[1] + xPosition
    wrappingBorder = @_dimensions[1] - block.width
    blockOutsideEnvironment = xPosition - wrappingBorder
    if blockOutsideEnvironment > 0
      @addBlock({x: 0, y: block.position.y}, blockOutsideEnvironment, true)
    return xPosition

  moveBlock: (block, direction) -> 
    ###
    _Returns:_ the block object, moved one step to the left or right, and one step down.
    ###
    switch direction
      when 'right'
        block.position.x++
        block.position.x = @checkXPosition(block)
      when 'left'
        block.position.x--
        block.position.x = @checkXPosition(block)
      when 'up'
        block.position.y--
      when 'down'
        block.position.y++  
    return

   moveAnimat: (@_animat) -> 
    ###
    _Returns:_ the block object, moved one step to the left or right, and one step down.
    ###
    direction = @calcAnimatDirection()
    #console.log direction
    switch direction
      when 'right'
        @_animat.position.x++
      when 'left'
        @_animat.position.x--
    @_animat.position.x = @checkXPosition(@_animat)
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