ticker = require( "../util/ticker" )()
EventDispatcher = require "../util/eventDispatcher"
instance = null

class Modal extends EventDispatcher
  constructor: ->
    super()
    @$modal = $( ".modal" )
    @$youtube = @$modal.find( ".youtube" )
    @$comment_container = @$modal.find( ".comment_container" )
    @$comment = @$comment_container.find( ".comment" )
    @$skip = @$modal.find( ".skip" )

    @comment_size = @$comment.size()
    @comment_param = []
    @youtube = null

    for i in [ 0...@comment_size ]
      @comment_param[ i ] = {}
      @comment_param[ i ].start = @$comment.eq( i ).data "start"
      @comment_param[ i ].shown = false

  setMovie: ->
    @youtube = new YT.Player "youtube",
      width: @$youtube.width()
      height: @$youtube.height()
      videoId: @$youtube.data "id"
      playerVars:
        rel: 0
        showinfo: 0
        modestbranding: 1
        controls: 0
        wmode: "opaque"

    @youtube.addEventListener "onReady", =>
      @youtube.playVideo()
      ticker.listen "CHECK_MOVIE_CURTIME", =>
        _cur_time = @youtube.getCurrentTime()
        for i in [ @comment_size - 1..0 ]
          return if @comment_param[ i ].shown
          if _cur_time > @comment_param[ i ].start
            @comment_param[ i ].shown = true
            @showComment i
            return

      @$skip.trigger "click" if window.DEBUG.state

    @youtube.addEventListener "onStateChange", ( state )=>
      if state.data == YT.PlayerState.ENDED
        ticker.clear "CHECK_MOVIE_CURTIME"
        @$modal.velocity opacity: [ 0, 1 ], DUR * 2, =>
          @$modal.hide()
          @dispatch "HIDE_MODAL"

  showComment: ( i )->
    @$comment.eq( i ).css display: "table-cell"
    @$comment_container.velocity opacity: [ 1, 0 ], DUR * 2
    setTimeout =>
      @$comment_container.velocity opacity: [ 0, 1 ], DUR, =>
        @$comment.eq( i ).hide()
    , 4000

  exec: ->
    @$skip.on "click", =>
      @youtube.stopVideo()
      ticker.clear "CHECK_MOVIE_CURTIME"
      @$modal.velocity opacity: [ 0, 1 ], DUR * 2, =>
        @$modal.hide()
        @dispatch "HIDE_MODAL"

    # youtube api
    window.onYouTubeIframeAPIReady = => @setMovie()
    $( "<script>" ).attr
      src: "https://www.youtube.com/iframe_api"
    .insertBefore $( "script" ).eq 0

getInstance = ->
  if !instance
    instance = new Modal()
  return instance

module.exports = getInstance
