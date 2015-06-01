###!
  *
  * VelocityJS.org (1.2.2). (C) 2014 Julian Shapiro.
  * MIT @license: en.wikipedia.org/wiki/MIT_License
  * VelocityJS.org jQuery Shim (1.0.1). (C) 2014 The jQuery Foundation.
  * MIT @license: en.wikipedia.org/wiki/MIT_License.
  *
###

###!
  *
  * Main Function
  *
###

if window._DEBUG
  if Object.freeze?
    window.DEBUG = Object.freeze window._DEBUG
  else
    window.DEBUG = state: true
else
  if Object.freeze?
    window.DEBUG = Object.freeze state: false
  else
    window.DEBUG = state: false

require "../js/velocity.min.js"
window.DUR = 500
indexInit = require "./indexInit"

$ ->
  ###################
  # DECLARE
  ###################
  
  $rock = $( ".rock" )
  $password = $( ".password" )
  $input = $password.find( "input" )
  $enter = $password.find( ".enter" )

  ENTER_KEY = 13

  ###################
  # PRIVATE
  ###################

  passCheck = ->
    _hash = CryptoJS.SHA256 $input.val()
    if _hash.toString() ==
       "a40a253fff002b6a8b08e9668c151b4a7696204765d57afb7f294e0248d56395"
      $rock.velocity opacity: [ 0, 1 ], ->
        $rock.hide()
        indexInit()
    else
      $password.velocity translateX: [ 5, 0 ], DUR / 10
      .velocity translateX: [ -5, 5 ], DUR / 10
      .velocity translateX: [ 5, -5 ], DUR / 10
      .velocity translateX: [ 0, 5 ], DUR / 10

  ###################
  # EVENT LISTENER
  ###################

  $input.on "focus", -> $input.attr( type: "password" ).val ""

  $enter.on "click", -> passCheck()

  $( window ).on "keydown", ( e )-> passCheck() if e.keyCode == ENTER_KEY
