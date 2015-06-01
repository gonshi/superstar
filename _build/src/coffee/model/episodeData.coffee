EventDispatcher = require "../util/eventDispatcher"

instance = null

class EpisodeData extends EventDispatcher
  constructor: ->
    super()
    @episode = {}

    @ageExp = /年齢: (.*?),/
    @episodeExp = /エピソード: (.*?)$/
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
        @episode[ _age ] = [] if !@episode[ _age ]?

        @episode[ _age ].push
          name: response.feed.entry[ i ].title.$t
          episode: response.feed.entry[ i ].content.$t.match( @episodeExp )[ 1 ]
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
