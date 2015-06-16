EventDispatcher = require "../util/eventDispatcher"
Throttle = require "../util/throttle"
instance = null
  
class ResizeHandler extends EventDispatcher
  constructor: -> super()

  exec: ->
    _throttle = new Throttle 500

    $( window ).on "resize", =>
      _throttle.last => @dispatch "RESIZED", this

  off: -> $( window ).off "resize"

getInstance = ->
  if !instance
    instance = new ResizeHandler()
  return instance

module.exports = getInstance
