EventDispatcher = require( "../util/eventDispatcher" )
instance = null

class Bg extends EventDispatcher
  constructor: ->
    super()
    @$wrapper = $( ".wrapper" )
    @$portrait_container = $( ".portrait_container" )
    @ROW_MAX = 20
    @FOOTER_HEIGHT = 145
    @PORTRAIT_HEIGHT = $( ".portrait" ).height()
    @PORTRAIT_ROW_MARGIN = parseInt( $( ".portrait_row" ).css "margin-top" )

    @mouseover_sound = new Audio()
    @mouseover_sound.src = "audio/mouseover.mp3"
    @mouseover_sound.volume = 0.2

    @open_sound = new Audio()
    @open_sound.src = "audio/open.mp3"

    @loaded_src = {} # save src and cache buster param

  imgLoaded: ( img_num )->
    _complete_func = ->
      $( ".portrait_pic_#{ img_num }" ).addClass "show"

    _complete_func() if @img[ img_num ].complete
      
    @img[ img_num ].onload = -> _complete_func()

  setPortrait: ( data )->
    @data = data
    @arragePortrait()

  arragePortrait: ->
    return if !@data? || !@wrapper_width?

    _count = 0
    _$portrait_row = $( "<div>" ).attr class: "portrait_row"
    _$p_clone = []
    _row_max = Math.floor( ( @wrapper_height - @FOOTER_HEIGHT ) /
               ( @PORTRAIT_HEIGHT + @PORTRAIT_ROW_MARGIN ) )
    _data_length = 0
    _data_key = []

    for i of @data
      _data_length += 1
      _data_key.push i

    _cur_row = 0
    _data_i = 0

    @$portrait_container.empty()

    @img = []

    while _cur_row < _row_max
      for j in [ 0...@data[ _data_key[ _data_i ] ].length ]
        if @data[ _data_key[ _data_i ] ][ j ].portrait != ""
          _$p = $( "<p>" ).attr class: "portrait"
          _$btn = $( "<button>" )

          @img.push new Image()
          @imgLoaded @img.length - 1

          _src = "#{ @data[ _data_key[ _data_i ] ][ j ].portrait }"

          @img[ @img.length - 1 ].setAttribute "data-age", _data_key[ _data_i ]
          @img[ @img.length - 1 ].setAttribute "data-id", j

          if @loaded_src[ _src ]?
            @img[ @img.length - 1 ].src = "#{ _src }?_=#{ @loaded_src[ _src ] }"
          else
            _date = Date.now()
            @img[ @img.length - 1 ].src = "#{ _src }?_=#{ _date }"
            @loaded_src[ _src ] = _date

          @img[ @img.length - 1 ].className +=
            " portrait_pic_#{ @img.length - 1 }"

          _$btn.append @img[ @img.length - 1 ]
          _$p.append _$btn

          _$p_clone.push _$p.clone()

          _$p.appendTo _$portrait_row

          _count += 1

          if _count == @ROW_MAX
            _count = 0

            _$p_clone[ i ].appendTo _$portrait_row for i in [ 0...@ROW_MAX ]
            _$p_clone = []

            _$portrait_row.appendTo @$portrait_container
            _$portrait_row.css width: _$p.outerWidth( true ) * @ROW_MAX * 2
            _$portrait_row.addClass "anim"

            # new div
            _$portrait_row = $( "<div>" ).attr class: "portrait_row"

            _cur_row += 1

      _data_i += 1
      _data_i = 0 if _data_i == _data_length

    @$portrait_container.css
      marginTop: ( @wrapper_height - @FOOTER_HEIGHT -
                   @$portrait_container.height() ) / 2

    @$portrait = $( ".portrait" )

    @$portrait.on "click", ( e )=>
      @open_sound.currentTime = 0
      @open_sound.play()

      @dispatch "PORTRAIT_CLICKED", this,
                $( e.currentTarget ).find( "img" ).attr( "data-age" ),
                $( e.currentTarget ).find( "img" ).attr( "data-id" )

    @$portrait.on "mouseenter", =>
      @mouseover_sound.currentTime = 0
      @mouseover_sound.play()

  setSize: ( wrapper_width, wrapper_height )->
    @wrapper_width = wrapper_width
    @wrapper_height = wrapper_height

getInstance = ->
  if !instance
    instance = new Bg()
  return instance

module.exports = getInstance
