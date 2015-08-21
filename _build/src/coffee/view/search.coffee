ticker = require( "../util/ticker" )()
instance = null

class Search
  constructor: ->
    @$win = $( window )

    @$search_container = $( ".search_container" )
    @$search = @$search_container.find( ".search" )
    @$enter = @$search_container.find( ".enter" )

    # result
    @$result_container = $( ".result_container" )
    @$result = @$result_container.find( ".result" )
    @$portrait = @$result.find( ".portrait" )
    @$name = @$result.find( ".name" )
    @$episode = @$result.find( ".episode" )
    @$age_num = @$result.find( ".age_container .num" )
    @$link = @$result.find( ".link" )

    # year
    @$year_container = $( ".year_container" )
    @$year_bar = $( ".year_bar" )
    @$year = @$year_container.find( ".year" )
    @$pin = @$year_container.find( ".pin" )
    @YEAR_WIDTH = parseInt( @$year.eq( 1 ).css "left" ) / 10 # ten year
    @PIN_WIDTH = parseInt @$pin.width()

    @cur_year_left = 0

    @RESULT_PADDING_HEIGHT = 130
    @ESCAPE_KEYCODE = 27

    @WIKI_LINK_ORIGIN = "https://ja.wikipedia.org/wiki/"

    @win_width = null

    # sound
    @roulette_sound = new Audio()
    @roulette_sound.src = "audio/roulette.mp3"
    @roulette_sound.volume = 0.2

    @open_sound = new Audio()
    @open_sound.src = "audio/open.mp3"

    @close_sound = new Audio()
    @close_sound.src = "audio/close.mp3"

  setEpisode: ( episode )->
    @episode = episode
    @origin_episode = $.extend true, {}, episode

  setPortrait: ( src, img_num )-> # introページのportrait
    console.log src, img_num

  dropPin: ( year )->
    # 年号アニメーション & ピン落とす
    @$pin.css
      left: @YEAR_WIDTH * year - @PIN_WIDTH / 2
      opacity: 0

    _next_year_left = @win_width / 2 -
                      @$pin.get( 0 ).getBoundingClientRect().left +
                      @cur_year_left

    @$year_bar.velocity
      translateX: _next_year_left
    , DUR * 2, =>
      @cur_year_left = _next_year_left

      @$pin.velocity
        opacity: [ 1, 0 ]
        translateY: [ 0, -20 ]
      , DUR, [ 200, 10 ], => @$result_container.removeClass "is_animating"

  search: ( age )->
    return if @search_interval

    @open_sound.currentTime = 0
    @open_sound.play()

    @search_interval = setInterval => # 連打防止
      if @episode?
        clearInterval @search_interval
        @search_interval = null

        if !@episode[ age ]?
          alert "該当する人物なし"
          return

        _id = Math.floor( Math.random() * @episode[ age ].length )
        @showResult age, @episode[ age ][ _id ].id

        @episode[ age ].splice _id, 1 # 同じ人が連続で出ないように

        if @episode[ age ].length == 0
          @episode[ age ] = $.extend true, [], @origin_episode[ age ]
    , 200

  showIntro: ->
    @$result_container.removeClass( "withoutPortrait" ).addClass "is_animating"

    @$name.text "ここに出てくる偉人は全員"
    @$episode.text "初めて泣いた。"
    @$age_num.text "0"

    _img = new Image()
    _img.src = "img/common/egg.png"
    @$portrait.empty()
    @$portrait.append _img

    @$result_container.show().velocity opacity: [ 1, 0 ], DUR, =>
      @$result_container.removeClass "is_animating"

      @roulette_sound.play()
      ticker.listen "AGE_COUNTUP", ( t )=>
        _age = Math.floor( t / 30 )
        if _age > 0
          ticker.clear "AGE_COUNTUP"
          @roulette_sound.pause()
          @roulette_sound.currentTime = 0
        else
          @$age_num.text _age

    @$result.css
      height: @$result.find( ".info" ).height() + @RESULT_PADDING_HEIGHT

  showResult: ( age, id )->
    _info = @origin_episode[ age ][ id ]

    @$result_container.removeClass( "withoutPortrait" ).addClass "is_animating"

    @$name.text _info.name
    @$episode.text _info.episode
    @$age_num.text ""
    #@$link.find( "a" ).attr
    #  href: "#{ @WIKI_LINK_ORIGIN }#{ encodeURIComponent( _info.name ) }"

    if _info.portrait.length > 0
      _img = new Image()
      _img.src = _info.portrait
      @$portrait.empty()
      @$portrait.append _img
    else
      @$result_container.addClass "withoutPortrait"

    @$result_container.show().velocity opacity: [ 1, 0 ], DUR, =>
      if _info.birth != "不明"
        @dropPin parseInt( age ) + parseInt( _info.birth )
      else
        @$result_container.removeClass "is_animating"

      @roulette_sound.play()
      ticker.listen "AGE_COUNTUP", ( t )=>
        _age = Math.floor( t / 30 )
        if _age > age
          ticker.clear "AGE_COUNTUP"
          @roulette_sound.pause()
          @roulette_sound.currentTime = 0
        else
          @$age_num.text _age

    @$result.css
      height: @$result.find( ".info" ).height() + @RESULT_PADDING_HEIGHT

  closeResult: ->
    @close_sound.currentTime = 0
    @close_sound.play()

    @$pin.velocity opacity: [ 0, 1 ], DUR

    @$result_container.velocity opacity: [ 0, 1 ], DUR, =>
      @$result_container.hide()

  setWinWidth: ( win_width )-> @win_width = win_width

  showSearchBar: ->
    return if parseInt( @$search_container.css "opacity" ) != 0

    @$search_container.velocity
      translateY: [ 0, -20 ]
      opacity: [ 1, 0 ]
    , DUR * 2

  exec: ->
    ###########################
    # EVENT LISTENER
    ###########################

    @$search.one "click", =>
      @$search.attr type: "number"
      .val( "" )
      .addClass "on"

    @$result_container.on "click", ( e )=>
      return if @$result_container.hasClass "is_animating"
      @closeResult() if $( e.target ).hasClass "close"

    @$win.on "keydown", ( e )=>
      if @$result_container.hasClass "is_animating" ||
         @$result_container.css( "display" ) == "none"
        return

      @closeResult() if e.keyCode == @ESCAPE_KEYCODE

    @$enter.on "click", => @search @$search.val()

    $( window ).on "keydown", ( e )=>
      @search @$search.val() if e.keyCode == ENTER_KEY

getInstance = ->
  if !instance
    instance = new Search()
  return instance

module.exports = getInstance
