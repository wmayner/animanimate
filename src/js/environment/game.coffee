###
# game.coffee
###

utils = require './utils'


HEIGHT = 36
WIDTH = 16

wrap = (x) -> (WIDTH + x) % WIDTH


class Block

  constructor: (@position, @width) ->
    @type = 'block'

  getCells: -> (
    {
      coords: {x: wrap(@position.x + i), y: @position.y}
      type: @type
    } for i in [0...@width]
  )

  move: (direction) ->
    switch direction
      when 'up'
        @position.y--
      when 'down'
        @position.y++
      when 'left'
        @position.x = wrap(@position.x - 1)
      when 'right'
        @position.x = wrap(@position.x + 1)


class Animat extends Block

  constructor: (@position) ->
    super
    @type = 'animat'
    @width = 3

  move: (direction) -> super unless direction is 'none'


class Game

  constructor: (@trial, @blockSize) ->
    @_timestep = 0
    @_direction = (if ((@trial.trialNum - 1) // WIDTH) % 2 then 'right' else 'left')
    @_block = new Block({x: 0, y: 0}, @blockSize)
    @_animat = new Animat({x: (@trial.trialNum-1) % WIDTH, y: 35})

  getDimensions: -> [HEIGHT, WIDTH]

  getBlock: -> @_block

  updateBlock: ->
    @_block.move('down')
    @_block.move(@_direction)

  getAnimat: -> @_animat

  getAnimatDirection: ->
    motorStates = @trial.lifeTable[@_timestep][-2...]
    switch (motorStates[0] + 2 * motorStates[1]) % 4
      when 1
        direction = 'right'
      when 2
        direction = 'left'
      else
        direction = 'none'
    return direction

  updateAnimat: ->
    @_animat.move(@getAnimatDirection())
    @_timestep++

  getCells: ->
    return @_block.getCells().concat @_animat.getCells()


module.exports = Game
