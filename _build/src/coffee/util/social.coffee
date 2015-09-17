instance = null

class Social
  exec: ->
    _type = {}
    for i in [ 0...arguments.length ]
      _type[ arguments[ i ] ] = true

    # facebook
    if _type.fb?
      fjs = document.getElementsByTagName( "script" )[ 0 ]
      return if document.getElementById "facebook-jssdk"
      js = document.createElement "script"
      js.id = "facebook-jssdk"
      js.src = "//connect.facebook.net/ja_JP/sdk.js#xfbml=1&" +
              "appId=959877374073274&version=v2.0"
      fjs.parentNode.insertBefore js, fjs

    # twitter
    if _type.tweet?
      window.twttr = (->
        fjs = document.getElementsByTagName( "script" )[ 0 ]
        return if document.getElementById "twitter-wjs"
        js = document.createElement "script"
        js.id = "twitter-wjs"
        js.src = "https://platform.twitter.com/widgets.js"
        fjs.parentNode.insertBefore js, fjs
        if window.twttr?
          return window.twttr
        else
          return ( t =
            _e: []
            ready:  ( f )-> t._e.push f
          )
      )()

    # hatena
    if _type.hatena?
      j = document.createElement "script"
      j.type = "text/javascript"
      j.src = "https://b.st-hatena.com/js/bookmark_button.js"
      j.async = "async"
      j.charset = "utf-8"
      s = document.getElementsByTagName( "script" )[0]
      s.parentNode.insertBefore j, s

    # pocket
    if _type.pocket?
      if !document.getElementById "pocket-btn-js"
        j = document.createElement "script"
        j.id = "pocket-btn-js"
        j.type = "text/javascript"
        j.src = "https://widgets.getpocket.com/v1/j/btn.js?v=1"
        w = document.getElementById "pocket-btn-js"
        document.body.appendChild j

    # gplus
    if _type.gplus?
      po = document.createElement "script"
      po.type = "text/javascript"
      po.async = true
      po.src = "https://apis.google.com/js/plusone.js"
      s = document.getElementsByTagName( "script" )[0]
      s.parentNode.insertBefore po, s

    # fb-share
    if _type.fb_share?
      if !_type.fb?
        fjs = document.getElementsByTagName( "script" )[ 0 ]
        return if document.getElementById "facebook-jssdk"
        js = document.createElement "script"
        js.id = "facebook-jssdk"
        js.src = "//connect.facebook.net/ja_JP/sdk.js#xfbml=1&" +
                "appId=959877374073274&version=v2.0"
        fjs.parentNode.insertBefore js, fjs

    # fb-share
    $( ".facebook" ).on "click", ( e )->
      FB.ui
        display: "popup"
        method: "feed"
        link: $(e.target).attr "data-url"
        name: $(e.target).attr "data-name"
        picture: $(e.target).attr "data-picture"
        description: $(e.target).attr "data-description"

    # tweet
    $( ".tweet a" ).on "click", ( e ) ->
      e.preventDefault()

      if window.screenLeft?
        _dualScreenLeft = window.screenLeft
        _dualScreenTop = window.screenTop
      else
        _dualScreenLeft = window.screen.left
        _dualScreenTop = window.screen.top

      if innerWidth?
        _windowWidth = window.innerWidth
        _windowHeight = window.innerHeight
      else if document.documentElement?.clientWidth?
        _windowWidth = document.documentElement.clientWidth
        _windowWidth = document.documentElement.clientHeight
      else
        _windowWidth = window.screen.width
        _windowWidth = window.screen.height

      _popupWidth = 650
      _popupHeight = 450

      _left = ((_windowWidth / 2) - (_popupWidth / 2)) + _dualScreenLeft
      _top = ((_windowHeight / 2) - (_popupHeight / 2)) + _dualScreenTop

      window.open $(e.currentTarget).attr("href"), "twitter",
                  "width=#{_popupWidth}, height=#{_popupHeight}, " +
                  "top=#{_top}, left=#{_left}"

  callback: ->
    # twitter
    window.twttr.ready ( twttr )->
      twttr.events.bind "tweet", ->
        _callback "tw"

    # facebook like
    window.onload = ->
      window.FB.Event.subscribe "edge.create",
        ( response )->
          _callback "fb" if response

    _callback = ( type )->
      console.log type

getInstance = ->
  if !instance
    instance = new Social()
  return instance

module.exports = getInstance
