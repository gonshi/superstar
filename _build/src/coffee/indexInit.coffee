ticker = require( "./util/ticker" )()
social = require( "./util/social" )()

indexInit = ->
  ###############################
  # DECLARE
  ###############################

  $modal = $( ".modal" )
  $youtube = $( ".youtube" )
  $comment_container = $( ".comment_container" )
  $comment = $comment_container.find( ".comment" )

  comment_size = $comment.size()
  comment_param = []
  youtube = null

  for i in [ 0...comment_size ]
    comment_param[ i ] = {}
    comment_param[ i ].start = $comment.eq( i ).data "start"
    comment_param[ i ].shown = false

  ##############################
  # PRIVATE
  ##############################

  setMovie = ->
    youtube = new YT.Player "youtube",
      width: $youtube.width()
      height: $youtube.height()
      videoId: $youtube.data "id"
      playerVars:
        rel: 0
        showinfo: 0
        modestbranding: 1
        controls: 0
        wmode: "opaque"

    youtube.addEventListener "onReady", ->
      youtube.playVideo()
      ticker.listen "CHECK_MOVIE_CURTIME", ->
        _cur_time = youtube.getCurrentTime()
        for i in [ comment_size - 1..0 ]
          return if comment_param[ i ].shown
          if _cur_time > comment_param[ i ].start
            comment_param[ i ].shown = true
            showComment i
            return

    youtube.addEventListener "onStateChange", ( state )->
      if state.data == YT.PlayerState.ENDED
        $modal.velocity opacity: [ 0, 1 ], DUR * 2, -> $modal.hide()

  showComment = ( i )->
    $comment.eq( i ).css display: "table-cell"
    $comment_container.velocity opacity: [ 1, 0 ], DUR * 2
    setTimeout ->
      $comment_container.velocity opacity: [ 0, 1 ], DUR, ->
        $comment.eq( i ).hide()
    , 4000

  ###############################
  # EVENT LISTENER
  ###############################

  ###############################
  # INIT
  ###############################
  
  # youtube api
  window.onYouTubeIframeAPIReady = -> setMovie()
  $( "<script>" ).attr
    src: "https://www.youtube.com/iframe_api"
  .insertBefore $( "script" ).eq 0

  social.exec "fb", "tweet"

module.exports = indexInit
