resizeHandler = require( "../controller/resizeHandler" )()
instance = null

class Bg
  constructor: ->
    @$wrapper = $( ".wrapper" )
    @$portrait_container = $( ".portrait_container" )
    @ROW_MAX = 20
    @FOOTER_HEIGHT = 80
    @PORTRAIT_HEIGHT = $( ".portrait" ).height()
    @PORTRAIT_ROW_MARGIN = parseInt( $( ".portrait_row" ).css "margin-top" )

    @data = null

  imgLoaded: ( img_num )->
    @img[ img_num ].onload = ->
      $( ".portrait_pic_#{ img_num }" ).addClass "show"

  setPortrait: ( data )->
    return if !@wrapper_width?

    _count = 0
    _$portrait_row = $( "<div>" ).attr class: "portrait_row"
    _$p_clone = []
    _row_max = Math.floor( ( @wrapper_height - @FOOTER_HEIGHT ) /
               ( @PORTRAIT_HEIGHT + @PORTRAIT_ROW_MARGIN ) )
    _data_length = 0
    _data_key = []

    for i of data
      _data_length += 1
      _data_key.push i

    _cur_row = 0
    _data_i = 0

    @data = data if @data == null

    @$portrait_container.empty()

    @img = []

    while _cur_row < _row_max
      for j in [ 0...data[ _data_key[ _data_i ] ].length ]
        if data[ _data_key[ _data_i ] ][ j ].portrait != ""
          _$p = $( "<p>" ).attr class: "portrait"

          @img.push new Image()
          @img[ @img.length - 1 ].src =
            "#{ data[ _data_key[ _data_i ] ][ j ].portrait }?_=#{ Date.now() }"

          @img[ @img.length - 1 ].className +=
            " portrait_pic_#{ @img.length - 1 }"

          @imgLoaded @img.length - 1
          _$p.append @img[ @img.length - 1 ]

          _$p_clone.push _$p.clone()

          _$p.appendTo _$portrait_row

          _count += 1

          if _count == @ROW_MAX
            _count = 0

            _$p_clone[ i ].appendTo _$portrait_row for i in [ 0...@ROW_MAX ]
            _$p_clone = []

            _$portrait_row.appendTo @$portrait_container
            _$portrait_row.css width: _$p.outerWidth( true ) * @ROW_MAX * 2

            # new div
            _$portrait_row = $( "<div>" ).attr class: "portrait_row"

            _cur_row += 1

      _data_i += 1
      _data_i = 0 if _data_i == _data_length

    @$portrait_container.css
      marginTop: ( @wrapper_height - @FOOTER_HEIGHT -
                   @$portrait_container.height() ) / 2

  exec: ->
    resizeHandler.listen "RESIZED", =>
      @wrapper_width = @$wrapper.width()
      @wrapper_height = @$wrapper.height()
      @setPortrait @data if @data != null

    resizeHandler.exec()
    resizeHandler.dispatch "RESIZED"

getInstance = ->
  if !instance
    instance = new Bg()
  return instance

module.exports = getInstance
