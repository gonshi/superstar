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
social = require( "./util/social" )()
episodeData = require( "./model/episodeData" )()
search = require( "./view/search" )()
bg = require( "./view/bg" )()
resizeHandler = require( "./controller/resizeHandler" )()

window.DUR = 500
window.EASE_IN_BACK = [ 0.6, -0.28, 0.735, 0.045 ]
window.EASE_OUT_BACK = [ 0.175, 0.885, 0.32, 1.275 ]
window.EASE_IN_OUT_BACK = [ 0.68, -0.55, 0.265, 1.55 ]
window.ENTER_KEY = 13
window.path = "./"

$ ->
  ########################
  # DECLARE
  ########################

  $win = $( window )
  $wrapper = $( ".wrapper" )
  $lock = $( ".lock" )
  $password = $( ".password_container" )
  $input = $password.find( ".password" )
  $enter = $password.find( ".enter" )
  is_intro = false

  ########################
  # PRIVATE
  ########################

  passCheck = ->
    _hash = CryptoJS.SHA256 $input.val()
    if _hash.toString() ==
       "a40a253fff002b6a8b08e9668c151b4a7696204765d57afb7f294e0248d56395"
      $lock.velocity opacity: [ 0, 1 ], ->
        $lock.hide()
    else
      $password.velocity translateX: [ 5, 0 ], DUR / 10
      .velocity translateX: [ -5, 5 ], DUR / 10
      .velocity translateX: [ 5, -5 ], DUR / 10
      .velocity translateX: [ 0, 5 ], DUR / 10

  ########################
  # EVENT LISTENER
  ########################

  $input.one "focus", -> $input.attr( type: "password" ).val ""

  $enter.on "click", -> passCheck()

  $( window ).on "keydown", ( e )-> passCheck() if e.keyCode == ENTER_KEY

  episodeData.listen "GOT_DATA", ( data )->
    search.setEpisode data
    bg.setPortrait data

  bg.listen "LOAD_IMG", ( src, img_num )->
    search.setPortrait src, img_num

  is_first = true
  resizeHandler.listen "RESIZED", ->
    return if !is_first
    is_first = false
    #return
    #location.reload() if is_intro
    _win_width = $win.width()
    _win_height = $win.height()
    _wrapper_width = $wrapper.width()
    _wrapper_height = $wrapper.height()

    search.setWinSize _win_width, _win_height
    bg.setSize _wrapper_width, _wrapper_height
    bg.arragePortrait()

  bg.listen "PORTRAIT_CLICKED", ( age, id )-> search.showResult age, id

  bg.listen "PORTRAIT_COUNTED", ( num )-> search.setPortraitMax num

  search.listen "FIN_INTRO", ->
    is_intro = false
    bg.finIntro()

  ###################
  # INIT
  ###################

  if location.search.match "skip"
    window.skip = true
  else
    window.skip = false

  social.exec "fb", "tweet"
  resizeHandler.dispatch "RESIZED"
  resizeHandler.exec()
  search.exec()
  search.showIntro()
  episodeData.getData()

  is_intro = true

  if window.DEBUG.state
    $lock.velocity opacity: [ 0, 1 ], ->
      $lock.hide()
