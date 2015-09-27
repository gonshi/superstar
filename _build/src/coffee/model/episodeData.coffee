EventDispatcher = require "../util/eventDispatcher"

instance = null

_count = 0
class EpisodeData extends EventDispatcher
  constructor: ->
    super()
    @episode = {}

    @ageExp = /年齢: (.*?),/
    @titleExp = /肩書: (.*?),/
    @episodeExp = /一言エピソード: (.*?),/
    @birthExp = /生年: (.*?),/
    @portraitLinkExp = /画像リンク: (.*?),/
    @publicDomainExp = /パブリックドメイン: (.*?),/
    @portraitExp = /画像: (.*?)$/
    @END_PHRASE = "以下未記述欄"

    ########################
    # EVENT LISTENER
    ########################

    window.gdata = {}
    window.gdata.io = {}
    window.gdata.io.handleScriptLoaded = ( response )=>
      _length = response.feed.entry.length

      for i in [ 0..._length ]
        response.feed.entry[ i ].content.$t =
          response.feed.entry[ i ].content.$t.replace /\n/g, ""
        break if response.feed.entry[ i ].title.$t == @END_PHRASE
        _age = response.feed.entry[ i ].content.$t.match( @ageExp )[ 1 ]

        _portrait_id =
          response.feed.entry[ i ].content.$t.match( @portraitExp )[ 1 ]

        if _portrait_id != "なし" &&
           (response.feed.entry[ i ].
           content.$t.match( @publicDomainExp )[ 1 ] == "TRUE" || true)
          _portrait = "#{ path }img/portrait/#{ _portrait_id }.png"
          _portrait_link =
            response.feed.entry[ i ].content.$t.match( @portraitLinkExp )[ 1 ]
        else
          _portrait = ""
          _portrait_link = ""

        @episode[ _age ] = [] if !@episode[ _age ]?

        @episode[ _age ].push
          id: @episode[ _age ].length
          name: response.feed.entry[ i ].title.$t
          title: response.feed.entry[ i ].content.$t.match( @titleExp )[ 1 ]
          episode: response.feed.entry[ i ].content.$t.match( @episodeExp )[ 1 ]
          birth: response.feed.entry[ i ].content.$t.match( @birthExp )[ 1 ]
          portraitLink: _portrait_link
          portrait: _portrait

      @dispatch "GOT_DATA", this, @episode

  getData: ->
    @src = "https://spreadsheets.google.com/feeds/list" +
           "/1ThmwlEue4zVhhlFMw7BsQd2Acpiv4Z4Uxz-5oYUlkaM" +
           "/od6/public/basic?alt=json-in-script"
    $( "head" ).append( $( "<script>" ).attr src: @src )

getInstance = ->
  if !instance
    instance = new EpisodeData()
  return instance

module.exports = getInstance
