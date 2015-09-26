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

    @is_intro = true

  finIntro: -> @is_intro = false

  imgLoaded: ( img_num )->
    _complete_func = =>
      if @is_intro
        @dispatch "LOAD_IMG", this, @img[ img_num ].src, img_num
      else
        $( ".portrait_pic_#{ img_num }" ).addClass "show"

      @portrait_shown_num += 1
      if @portrait_num != null && @portrait_shown_num == @portrait_num
        @dispatch "FIN_ARRANGE"

    setTimeout =>
      if @img[ img_num ].width > 0
        _complete_func()
      else
        @img[ img_num ].onload = -> _complete_func()
    , 100

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

    _portrait_num = 0

    @$portrait_container.empty()

    @portrait_shown_num = 0
    @portrait_num = null

    @img = []

    while _cur_row < _row_max
      for j in [ 0...@data[ _data_key[ _data_i ] ].length ]
        if @data[ _data_key[ _data_i ] ][ j ].portrait != ""
          _$p = $( "<p>" ).attr class: "portrait"
          _$btn = $( "<button>" )

          @img.push new Image()
          _src = "#{ @data[ _data_key[ _data_i ] ][ j ].portrait }"
          @img[ @img.length - 1 ].setAttribute "data-age", _data_key[ _data_i ]
          @img[ @img.length - 1 ].setAttribute "data-id", j

          if @loaded_src[ _src ]?
            @img[ @img.length - 1 ].src = "#{ _src }"
          else
            @img[ @img.length - 1 ].src = "#{ _src }"
            @loaded_src[ _src ] = Date.now()

          @img[ @img.length - 1 ].className +=
            " portrait_pic_#{ @img.length - 1 }"

          _$btn.append @img[ @img.length - 1 ]
          _$p.append _$btn

          _$p_clone.push _$p.clone() # 1人の画像を1つの列に2枚置きます。
                                     # これはスライドでループするときに
                                     # シームレスに繋げるためです。

          _$p.appendTo _$portrait_row

          _count += 1

          # 1列の最大値まで画像が達したら、折返すように同じ画像を再度配置します。
          if _count == @ROW_MAX
            _count = 0

            for i in [ 0...@ROW_MAX ]
              _$p_clone[ i ].appendTo _$portrait_row
              @imgLoaded @img.length - 1 - i # load完了イベント登録

            _$p_clone = []

            _$portrait_row.appendTo @$portrait_container
            _$portrait_row.css width: _$p.outerWidth( true ) * @ROW_MAX * 2
            _$portrait_row.addClass "anim"

            # new div
            _$portrait_row = $( "<div>" ).attr class: "portrait_row"

            _cur_row += 1

      _data_i += 1
      _data_i = 0 if _data_i == _data_length

    @portrait_num = @$portrait_container.find( ".portrait" ).size()
    @dispatch "PORTRAIT_COUNTED", this, @portrait_num

    @$portrait_container.css
      marginTop: ( @wrapper_height - @FOOTER_HEIGHT -
                   @$portrait_container.height() ) / 2

    @$portrait = @$portrait_container.find( ".portrait" )

    @$portrait.on "click", ( e )=>
      @open_sound.currentTime = 0
      @open_sound.play() if !isSp

      @dispatch "PORTRAIT_CLICKED", this,
                $( e.currentTarget ).find( "img" ).attr( "data-age" ),
                $( e.currentTarget ).find( "img" ).attr( "data-id" )

    @$portrait.on "mouseenter", =>
      @mouseover_sound.currentTime = 0
      @mouseover_sound.play() if !isSp

  setSize: ( wrapper_width, wrapper_height )->
    @wrapper_width = wrapper_width
    @wrapper_height = wrapper_height

getInstance = ->
  if !instance
    instance = new Bg()
  return instance

module.exports = getInstance
