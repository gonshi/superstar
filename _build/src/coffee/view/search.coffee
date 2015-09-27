EventDispatcher = require( "../util/eventDispatcher" )

ticker = require( "../util/ticker" )()
instance = null
30
class Search extends EventDispatcher
  constructor: ->
    super()
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
    @$portrait_name = @$result.find( ".portrait_name" )
    @$portrait_title = @$result.find( ".portrait_title" )
    @$link = @$result.find( ".link" )
    @$tweet_a = @$result.find( ".tweet a" )
    @$facebook = @$result.find( ".facebook" )

    # year
    @$year_container = $( ".year_container" )
    @$year_bar = $( ".year_bar" )
    @$year = @$year_container.find( ".year" )
    @$pin = @$year_container.find( ".pin" )
    @YEAR_WIDTH = parseInt( @$year.eq( 1 ).css "left" ) / 10 # ten year
    @PIN_WIDTH = parseInt @$pin.width()

    # portrait container (introのアニメーションのため、
    # 背景のportraitにもアクセスできるようにする)
    @$portrait_container = $( ".portrait_container" )
    @is_diffusing = false

    # values
    @portrait_loaded = []
    @cur_year_left = 0
    @RESULT_PADDING_HEIGHT = if isSp then 390 else 269
    @ESCAPE_KEYCODE = 27
    @WIKI_LINK_ORIGIN = "https://ja.wikipedia.org/wiki/"
    @win_width = null

    # illust
    @$illust_container = $(".illust_container")

    # about
    @$aboutBtn = $(".aboutBtn")
    @$about_container = $(".about_container")

    @$room = $( ".room" )
    @room_canvas = @$room.get 0
    @room_ctx = @room_canvas.getContext "2d"
    @light_grad = new Image()
    @light_grad.src = "img/illust/light_grad.png"

    # social
    @$social_container_illust = $(".social_container-illust")

    @ILLUST_NAME =
      wright: "ウィルバー・ライト"
      columbus: "コロンブス"
      oh: "王貞治"
      newton: "ニュートン"
      beethoven: "ベートーベン"
      zuckerberg: "マーク・ザッカーバーグ"
      jack: "ジャック・ドーシー"
      bolt: "ウサインボルト"
      michael: "マイケル・ジャクソン"
      edison: "エジソン"

    @ILLUST_AGE = # 年齢指定がある場合
      michael: 26
      edison: 32

    @ILLUST_NAME_ARR = []
    _exclude_list = [ "zuckerberg", "jack" ]

    for i of @ILLUST_NAME
      _not_exclude = true
      for j in [ 0..._exclude_list.length]
        if i == _exclude_list[ j ]
          _not_exclude = false
          break
      @ILLUST_NAME_ARR.push i if _not_exclude

    # sound
    @roulette_sound = new Audio()
    @roulette_sound.src = "audio/roulette.mp3"

    @open_sound = new Audio()
    @open_sound.src = "audio/open.mp3"

    @close_sound = new Audio()
    @close_sound.src = "audio/close.mp3"

    # loaded portrait count (for intro)
    @loaded_portrait_num = 0

    # illust SE
    @oh_sound = new Audio()
    @oh_sound.src = "audio/oh.mp3"
    @beethoven_sound = new Audio()
    @beethoven_sound.src = "audio/beethoven.mp3"
    @wright_sound = new Audio()
    @wright_sound.src = "audio/wright.mp3"
    @step_sound = new Audio()
    @step_sound.src = "audio/step.mp3"
    @fall_sound = new Audio()
    @fall_sound.src = "audio/fall.mp3"
    @cheer_sound = new Audio()
    @cheer_sound.src = "audio/cheer.mp3"

  animIllust: ( name )-> # イラストによるアニメーション発動
    for i in [ 0...@ILLUST_NAME_ARR.length ] # 一度出現したアニメーションはもう出さない
      if @ILLUST_NAME_ARR[ i ] == name
        @ILLUST_NAME_ARR.splice i, 1
        break

    @$anim_illust = @$illust_container.find(".illust-#{ name }")

    switch name
      when "wright"
        @wright_sound.play() if !isSp
        @$anim_illust.show().velocity
          translateX: [-@$win.width() - 1000, 0]
          translateY: [300, 0]
        , DUR * 7, "easeInSine", => @showResultByName name
      when "columbus"
        @$anim_illust.show().removeClass( "break" ).velocity
          translateY: [@$win.height() - @$year_container.height() + 80, 0]
        , DUR * 2, "easeInCubic", =>
          @$anim_illust.
          addClass( "break" ).
          velocity(
            translateY: @$win.height() - @$year_container.height() + 60
          , 30 ).
          velocity(
            translateY: @$win.height() - @$year_container.height() + 57
          , 30 ).
          velocity(
            translateY: @$win.height() - @$year_container.height() + 63
          , 10 ).
          velocity(
            translateY: @$win.height() - @$year_container.height() + 60
          , 10 )

        setTimeout ( => @showResultByName name ), DUR * 4

      when "oh"
        @oh_sound.play() if !isSp
        @$anim_illust.show().velocity
          translateX: [@$win.width() + 1000, 0]
          translateY: [-@$win.height() + @$year_container.height(), 0]
          rotateZ: [-720, 0]
        , DUR * 4, "easeOutSine"
        setTimeout ( => @showResultByName name ), DUR * 2

      when "newton"
        @$anim_illust.show().removeClass "fall"
        @$anim_illust.find(".illust-newton_tree").show()

        @step_sound.play() if !isSp

        _id = 1
        _interval = setInterval =>
          if _id < 5
            @$anim_illust.find(".illust-newton_chara_container").
            attr("data-id": _id % 2 + 1).css left: -50 + 100 * _id
          else if _id == 5
            @$anim_illust.find(".illust-newton_chara_container").
            attr "data-id": 3
          if _id == 7
            @step_sound.pause()

            clearInterval _interval
            @$anim_illust.addClass "fall"

            @fall_sound.play() if !isSp

            setTimeout ( => @showResultByName name ), DUR * 4

          _id += 1
        , 400
      when "beethoven"
        @beethoven_sound.volume = 0
        $(@beethoven_sound).animate volume: 1, DUR * 4
        @beethoven_sound.play() if !isSp
        @$anim_illust.show()

        for i in [0...4]
          @$anim_illust.find( ".illust-beethoven_tone" ).
          eq(i).velocity
            translateX: [-@$win.width() - 1000, 0]
          ,
            queue: false
            duration: DUR * 12
            easing: "linear"

          @$anim_illust.find( ".illust-beethoven_tone" ).eq(i).velocity
            translateY: 30 + Math.random() * 50
          ,
            duration: DUR + Math.random() * DUR * 2
            loop: true
            easing: "linear"

        setTimeout =>
          for i in [0...4]
            @$anim_illust.find( ".illust-beethoven_tone" ).eq(i).
            velocity "stop", true

          $(@beethoven_sound).animate volume: 0, DUR * 4, =>
            @beethoven_sound.pause()

          @showResultByName name
        , DUR * 12

      when "zuckerberg"
        @$anim_illust.show().velocity translateX: [-200, 0]
        , DUR, =>
          setTimeout ( => @showResultByName name ), DUR * 2
      when "jack"
        @$anim_illust.show().velocity translateX: [-200, 0]
        , DUR, =>
          setTimeout ( => @showResultByName name ), DUR * 2
      when "bolt"
        @$anim_illust.show().velocity opacity: 1, DUR
        _$timer = @$anim_illust.find(".illust-bolt_timer")
        _$pic = @$anim_illust.find(".illust-bolt_pic")

        ticker.listen "BOLT_TIMER", ( t )->
          _t = Math.floor( ( t + 5800 ) / 10 )

          if _t >= 958
            _$timer.text "09:58"
            ticker.clear "BOLT_TIMER"
          else
            _t = ( "00" + _t ).slice -4
            _$timer.text( "#{ _t }".slice(0, 2) + ":" +
                          "#{ _t }".slice(2, 4) )

        setTimeout =>
          _i = 1

          @bolt_anim = setInterval ->
            _$pic.attr "data-id": _i++ % 15 + 1
          , 30

          _$pic.velocity translateX: [@$win.width() + 600, 0]
          , DUR * 3, "linear", =>
            clearInterval @bolt_anim
            @showResultByName name

          if !isSp
            setTimeout ( => @cheer_sound.play() ), 800
        , 2500
      when "michael"
        _i = 1

        @michael_anim = setInterval =>
          @$anim_illust.attr "data-id": _i++ % 7 + 1
        , 150

        @$anim_illust.velocity translateX: [@$win.width() + 600, 0]
        , DUR * 8, "linear", =>
          clearInterval @michael_anim
          @showResultByName name
      when "edison"
        @room_canvas.width = @win_width
        @room_canvas.height = @win_height
        @room_ctx.fillRect 0, 0, @room_canvas.width, @room_canvas.height

        @$anim_illust.show()

        @$room.show().velocity opacity: 1, DUR, =>
          @$anim_illust.find( ".illust-edison-off" ).velocity
            opacity: 1
            translateY: [ 0, 100 ]
          ,
            duration: DUR
            delay: DUR * 2
            complete: =>
              _dur = DUR * 2
              _delay = DUR * 2

              ticker.listen "LIGHT_BLUR", ( t )=>
                _t = t - _delay
                return if _t < 0

                @room_ctx.globalCompositeOperation = "source-over"
                @room_ctx.fillRect(
                  0, 0, @room_canvas.width, @room_canvas.height
                )
                @room_ctx.globalCompositeOperation = "xor"

                @room_ctx.globalAlpha = _t / _dur
                @room_ctx.drawImage(
                  @light_grad,
                  ( @room_canvas.width - @light_grad.width ) / 2,
                  ( @room_canvas.height - @light_grad.height ) / 2
                )

                @$anim_illust.find( ".illust-edison-on" ).css opacity: _t / _dur

                if _t >= _dur
                  ticker.clear "LIGHT_BLUR"
                  setTimeout =>
                    @showResultByName name
                    @$room.one "click", =>
                      @$room.velocity opacity: 0, => @$room.hide()
                      @closeResult()
                  , DUR * 3

  diffusePortrait: ( diffuse_num )-> # introページでportrait画像をばら撒く演出
    _diffused_num = 0

    _result_rect = @$result.get( 0 ).getBoundingClientRect()

    _portrait_row_width =
      @$portrait_container.find( ".portrait_row" ).width()

    _portrait_i_arr = []
    for i in [ 0...@$portrait.find( "img" ).size() ]
      _portrait_i_arr.push i

    for i in [ 0...diffuse_num ]
      _portrait_i = Math.floor( Math.random() * _portrait_i_arr.length )

      _$portrait = @$portrait.find( "img" ).
      eq _portrait_i_arr[ _portrait_i ]

      _portrait_id = _$portrait.attr "data-id"

      _portrait_i_arr.splice _portrait_i, 1

      _bg_portrait_i = @$portrait_container.
                       find( ".portrait_pic_#{ _portrait_id }.selected" ).
                       size()

      _targetPortrait =
        @$portrait_container.
        find( ".portrait_pic_#{ _portrait_id }" ).
        get _bg_portrait_i

      _targetPortrait.className += " selected"

      do (_$portrait, _targetPortrait)=>
        if skip
          _dur = 10
          _delay = 0
        else
          _dur = DUR * 6
          _delay = 10 * i

        if $( _targetPortrait ).parents( ".portrait_row" ).index() % 2 == 0
          _vec = -1
        else
          _vec = 1

        _target_left =
          _targetPortrait.getBoundingClientRect().left +
          _portrait_row_width / 2 / 150 *
          ( ( _dur + _delay ) / 1000 ) * _vec
          # 150: transition sec, 2: duration sec

        _target_top = _targetPortrait.getBoundingClientRect().top

        if _target_left + _targetPortrait.offsetWidth > _result_rect.left &&
           _target_left < _result_rect.right &&
           _target_top + _targetPortrait.offsetHeight > _result_rect.top &&
           _target_top < _result_rect.bottom
          _target_opacity = 0.02 # 移動先がモーダルの裏に隠れている場合、その明度に合わせる
        else
          _target_opacity = 0.2

        if isSp
          _$portrait.css
            position: "fixed"
            top: _target_top
            left: _target_left
            width: _targetPortrait.offsetWidth
            height: _targetPortrait.offsetHeight

          $(_targetPortrait).velocity
            opacity: [ 1, 0 ]
          , _dur, =>
            _$portrait.remove()
            $(_targetPortrait).removeAttr "style"
            _targetPortrait.className += " show"
            @is_diffusing = false
        else
          # モーダル上の位置から、背景側の
          # 同一ポートレートの位置までアニメーションさせる
          _$portrait.css
            position: "fixed"
            top: _$portrait.get( 0 ).getBoundingClientRect().top
            left: _$portrait.get( 0 ).getBoundingClientRect().left
            width: _$portrait.width()
            height: _$portrait.height()
          .velocity # 横位置
            left: _target_left
            width: _targetPortrait.offsetWidth
            height: _targetPortrait.offsetHeight
            opacity: [ _target_opacity, 0 ]
          ,
            duration: _dur
            delay: _delay
            easing: EASE_OUT_BACK
            complete: =>
              _$portrait.remove()
              _targetPortrait.className += " transition" if skip
              _targetPortrait.className += " show"
              @is_diffusing = false if ++_diffused_num == diffuse_num

          _$portrait.velocity top: _target_top # 縦位置
          ,
            duration: _dur
            delay: _delay
            easing: "easeOutSine"
            queue: false

  setEpisode: ( episode )->
    @episode = episode
    @origin_episode = $.extend true, {}, episode

  setPortrait: ( src, img_num )-> # introページのportraitをモーダル上にappendしていいく
    return unless src

    _pic = new Image()
    _pic.src = src
    _pic.setAttribute "data-id", img_num

    for i in [ 0...2 ] # 背景側も、スライド用に各画像2枚ずつあるので、こちらでも2枚ずつ置いていく
      @$portrait.append $( _pic ).clone()
      @loaded_portrait_num += 1

      if @loaded_portrait_num == Math.floor( @PORTRAIT_MAX / 3 )
        # 読み込み終えたことをチェックする。tickerのTIMER_FROM_STARTで
        # この値を監視し、trueであれば(画像用意が完了していれば)diffuseイベントを開始させる

        @portrait_loaded[ 0 ] = true
      else if @loaded_portrait_num == Math.floor( @PORTRAIT_MAX / 3 ) * 2
        @portrait_loaded[ 1 ] = true
      else if @loaded_portrait_num == @PORTRAIT_MAX
        @portrait_loaded[ 2 ] = true

  dropPin: ( year )->
    # 年号アニメーション & ピン落とす
    @$pin.css
      left: @YEAR_WIDTH * year - @PIN_WIDTH / 2
      opacity: 0

    _next_year_left = @win_width / 2 -
                      @$pin.get( 0 ).getBoundingClientRect().left +
                      @cur_year_left

    @$year_bar.velocity # 該当位置までバーをスライドさせる
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
    @open_sound.play() if !isSp

    # 全角・半角変換
    age = age.replace( /[Ａ-Ｚａ-ｚ０-９]/g,( s )->
      return String.fromCharCode( s.charCodeAt(0) - 0xFEE0 )
    )

    # 文字列排除
    age = parseInt age

    @search_interval = setInterval => # 連打防止
      if @episode?
        clearInterval @search_interval
        @search_interval = null

        if !@episode[ age ]?
          @showResult 0, 0, true # 0, 0: dummy data
          return

        _id = Math.floor( Math.random() * @episode[ age ].length )
        @showResult age, @episode[ age ][ _id ].id
    , 200

  setPortraitMax: ( num )-> @PORTRAIT_MAX = num

  showIntro: ->
    @$result_container.removeClass( "withoutPortrait" ).addClass "is_animating"

    @$name.text "ここに出てくる偉人はみんな"
    @$name.css fontSize: 28
    @$result.find( ".name_particle" ).hide() # "は(助詞)" を消す

    @$result_container.show().velocity opacity: [ 1, 0 ], DUR, =>
      @$result_container.removeClass "is_animating"

    @$result.css opacity: 1

    if isSp
      @$result.css
        height: @$result.find( ".info" ).height() + 120
    else
      @$result.css
        height: @$result.find( ".info" ).height() + @RESULT_PADDING_HEIGHT

    ticker.listen "TIMER_FROM_START", ( t )=>
      _dur = if skip then 10 else DUR

      for i in [ 0...3 ]
        if t > _dur * 16 * i  # _wait_span(ms) 置きにdiffuseイベントを発生させる
          if @portrait_loaded[ i ] # ロードが完了したタイミングで
            if @is_diffusing ||
               i == 1 && @portrait_loaded[ 0 ] != null ||
               i == 2 && @portrait_loaded[ 1 ] != null
              return # 1つ前のフェーズが終わっていなければ開始しない

            if i == 2
              _diffuse_num = @PORTRAIT_MAX -
                             Math.floor( @PORTRAIT_MAX * 1 / 3 ) * 2
            else
              _diffuse_num = Math.floor( @PORTRAIT_MAX * 1 / 3 )

            @portrait_loaded[ i ] = null # null は、そのフェーズが終了したことを表す

            @$age_num.text i

            switch i
              when 0
                @$episode.text "初めて泣いた。"
              when 1
                @$episode.text "歩き始めた。"
              when 2
                @$episode.text "笑った。"
                ticker.clear "TIMER_FROM_START"

            @$result.find( ".skip" ).show()
            @$result.find( ".info" ).velocity opacity: 1, _dur * 2

            @is_diffusing = true
            do ( i )=>
              setTimeout =>
                @diffusePortrait _diffuse_num
                @$result.find( ".info" ).velocity opacity: 0
                ,
                  duration: _dur * 2
                  delay: _dur * 2
              , _dur * 6

              if i == 2 # イントロ終了。本編への繋ぎ演出を行う。
                setTimeout =>
                  @$result_container.find( ".skip" ).hide()

                  @$result.velocity
                    backgroundColorAlpha: 0
                    borderColorAlpha: 0
                  , _dur

                  if isSp
                    _width = 490
                    _bottom = 0
                  else
                    _width = 580
                    _bottom = 35

                  @$result.find( ".logo" ).velocity
                    width: _width
                    height: _width * 300 / 580
                    bottom: _bottom
                  ,
                    duration: _dur * 1.5
                    delay: _dur * 2
                    easing: EASE_IN_BACK
                    complete: =>
                      @$result.find( ".logo" ).velocity
                        opacity: 0
                        translateY: -120
                      ,
                        duration: _dur
                        delay: _dur * 6
                        easing: EASE_IN_BACK
                        complete: =>
                          @$result_container.velocity opacity: [ 0, 1 ]
                          , _dur * 3, =>
                            @$result_container.hide()
                            @$result.removeAttr "style"
                            @$result.find( ".info" ).removeAttr "style"
                            @$result.find( ".logo" ).removeAttr "style"
                            @$result.find( ".name_particle" ).show()
                            @$result.find( ".social_container" ).show()
                            @$result.find( ".close_container" ).show()
                            @$result.find( ".portrait_txt" ).css opacity: 1
                            @$social_container_illust.show()
                            @$aboutBtn.show()

                            # social button event
                            @$social_container_illust.
                            find( ".facebook" ).one "click", =>
                              if @$result_container.css( "display" ) == "block"
                                @closeResult()
                              @animIllust "zuckerberg"

                            @$social_container_illust.
                            find( ".tweet" ).one "click", =>
                              if @$result_container.css( "display" ) == "block"
                                @closeResult()
                              @animIllust "jack"

                            @dispatch "FIN_INTRO"

                            # ランダムでアニメーションを流す
                            if location.search == "?bolt"
                              @anim_timer = setTimeout =>
                                @animIllust "bolt"
                              , Math.random() * 5000 + 5000
                            else
                              @anim_timer = setTimeout =>
                                @animIllust(
                                  @ILLUST_NAME_ARR[Math.floor(Math.random() *
                                  @ILLUST_NAME_ARR.length)]
                                )
                              , Math.random() * 5000 + 5000

                            @fin_intro = true

                          @showSearchBar()
                , _dur * 12

  showResultByName: ( name )->
    # name の探索
    for i of @episode
      if @ILLUST_AGE[ name ]? && parseInt( i ) != @ILLUST_AGE[ name ]
        continue # 指定された年齢と異なる場合

      for j in [ 0...@episode[i].length ]
        if @episode[i][j].name == @ILLUST_NAME[ name ]
          @showResult i, @episode[i][j].id
          return

  showResult: ( age, id, is_nobody )->
    # 検索窓がまだ出ていないときはブロック
    return if parseInt( @$search_container.css "opacity" ) != 1

    clearTimeout @anim_timer if @anim_timer?

    # 既に表示中の場合はブロック
    return if @$result_container.css( "display" ) == "block"

    _info = @origin_episode[ age ][ id ]

    for i in [ 0...@ILLUST_NAME_ARR.length ]
      # アニメーション演出がある場合、まずアニメーションを実行する
      if _info.name == @ILLUST_NAME[ @ILLUST_NAME_ARR[ i ] ] &&
         !@ILLUST_AGE[ _info.name ]? ||
         @ILLUST_AGE[ _info.name ] == parseInt( age )
        @animIllust @ILLUST_NAME_ARR[ i ]
        return

    @$result_container.removeClass( "withoutPortrait" ).addClass "is_animating"

    @$result_container.addClass "nobody" if is_nobody?

    @$name.text _info.name
    @$portrait_name.text _info.name
    @$episode.html _info.episode
    @$age_num.text age
    @$portrait_title.text _info.title
    @$link.find( "a" ).attr
      href: "#{ @WIKI_LINK_ORIGIN }#{ encodeURIComponent( _info.name ) }"

    # set social text
    @$tweet_a.attr(
      "href": "http://twitter.com/share?url=#{@$tweet_a.attr "data-url"}" +
      "&text=#{ encodeURIComponent( "#{ @$result.find( ".info" ).text().
      replace( /\n| |　/g, "" ) } - #{ @$tweet_a.attr "data-title" }" ) }"
    )

    @$facebook.attr "data-description": @$result.find( ".info" ).text().
    replace( /\n| |　/g, "" )

    @$age_num.text "0"

    # set layout
    if _info.name.length > 11
      @$name.css fontSize: 28
    else if _info.name.length > 10
      @$name.css fontSize: 32
    else
      @$name.css fontSize: 36

    @$result.css opacity: 1
    @$result.find( ".info" ).css opacity: 1
    @$result.find( ".portrait" ).show()

    if _info.portrait.length > 0
      _img = new Image()
      _img.src = _info.portrait
      _img.style.opacity = 1
      @$portrait.find( "a" ).attr( href: _info.portraitLink ).
      empty().
      append _img
    else
      @$result_container.addClass "withoutPortrait"

    @$result_container.show().velocity opacity: [ 1, 0 ], DUR, =>
      if _info.birth != "不明"
        @dropPin parseInt( age ) + parseInt( _info.birth )
      else
        @$result_container.removeClass "is_animating"

      @roulette_sound.volume = 0.2
      @roulette_sound.play() if !isSp
      ticker.listen "AGE_COUNTUP", ( t )=>
        _age = Math.floor( t / 30 )
        if _age > age
          ticker.clear "AGE_COUNTUP"
          $( @roulette_sound ).animate volume: 0, 100, =>
            @roulette_sound.pause()
            @roulette_sound.currentTime = 0
          @$age_num.text age
        else
          @$age_num.text _age

    if @$result_container.hasClass "withoutPortrait"
      @$result.css
        height: @$result.find( ".info" ).height() +
                @RESULT_PADDING_HEIGHT - 80
    else if @$result_container.hasClass "nobody"
      @$result.css
        height: @$result.find( ".info" ).height() +
                @RESULT_PADDING_HEIGHT + 120
    else
      @$result.css
        height: @$result.find( ".info" ).height() + @RESULT_PADDING_HEIGHT

    # 同じ人が連続で出ないようにする
    @episode[ age ].splice id, 1
    if @episode[ age ].length == 0
      @episode[ age ] = $.extend true, [], @origin_episode[ age ]

  closeResult: ->
    return unless @fin_intro?

    @close_sound.currentTime = 0
    @close_sound.play() if !isSp

    @$pin.velocity opacity: [ 0, 1 ], DUR

    @$anim_illust.hide() if @$anim_illust?

    @$result_container.velocity opacity: [ 0, 1 ], DUR, =>
      @$result_container.removeClass( "nobody" ).hide()

      # ランダムで次のアニメーションを流す
      if @ILLUST_NAME_ARR.length > 0
        @anim_timer = setTimeout =>
          @animIllust(
            @ILLUST_NAME_ARR[Math.floor(Math.random() *
            @ILLUST_NAME_ARR.length)]
          )
        , Math.random() * 5000 + 5000

  setWinSize: ( win_width, win_height) ->
    @win_width = win_width
    @win_height = win_height

  showSearchBar: ->
    return if parseInt( @$search_container.css "opacity" ) != 0

    @$search_container.velocity
      top: [ 0, -40 ]
      opacity: [ 1, 0 ]
    ,
      duration: DUR * 3
      mobileHA: false

  exec: ->
    ###########################
    # EVENT LISTENER
    ###########################

    @$search.one "click", =>
      @$search.val( "" ).addClass "on"

    @$result_container.on "click", ( e )=>
      return if @$result_container.hasClass "is_animating"
      @closeResult() if $( e.target ).hasClass "close"

    @$win.on "keydown", ( e )=>
      if @$result_container.hasClass "is_animating" ||
         @$result_container.css( "display" ) == "none"
        return

      @closeResult() if e.keyCode == @ESCAPE_KEYCODE

    @$enter.on "click", => @search @$search.val()

    @$result_container.find( ".skip" ).one "click", =>
      window.skip = true
      @$result_container.find( ".skip" ).hide()
      @$result.velocity opacity: 0, DUR

    @$aboutBtn.on "click", =>
      if @$result_container.css( "display" ) == "block"
        @$result_container.find( ".close" ).trigger "click"

      @$about_container.show().velocity opacity: 1, DUR

    @$about_container.on "click", (e) =>
      if $(e.target).hasClass "close"
        @$about_container.velocity opacity: 0, DUR, =>
          @$about_container.hide()

    $( window ).on "keydown", ( e )=>
      @search @$search.val() if e.keyCode == ENTER_KEY

getInstance = ->
  if !instance
    instance = new Search()
  return instance

module.exports = getInstance
