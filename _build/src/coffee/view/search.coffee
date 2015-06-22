instance = null

class Search
  constructor: ->
    @$search_container = $( ".search_container" )
    @$search = @$search_container.find( ".search" )
    @$enter = @$search_container.find( ".enter" )

    # result
    @$result_container = $( ".result_container" )
    @$result = @$result_container.find( ".result" )
    @$name = @$result.find( ".name" )
    @$episode = @$result.find( ".episode" )
    @$age_num = @$result.find( ".age .num" )

  setEpisode: ( episode )-> @episode = episode

  search: ( age )->
    return if @search_interval

    @search_interval = setInterval =>
      if @episode?
        clearInterval @search_interval
        @search_interval = null
        
        if !@episode[ age ]?
          alert "該当する人物なし"
          return

        _index = Math.floor( Math.random() * @episode[ age ].length )
        @showResult age, @episode[ age ][ _index ]
    , 200

  showResult: ( age, info )->
    @$name.text info.name
    @$episode.text info.episode
    @$age_num.text age

    @$result_container.show().velocity opacity: [ 1, 0 ], DUR

  exec: ->
    ###########################
    # EVENT LISTENER
    ###########################
    
    @$search.one "click", =>
      @$search.attr type: "number"
      .val( "" )
      .addClass "on"

    @$result_container.on "click", ( e )=>
      if $( e.target ).hasClass "close"
        @$result_container.velocity opacity: [ 0, 1 ], DUR, =>
          @$result_container.hide()

    @$enter.on "click", => @search @$search.val()

    $( window ).on "keydown", ( e )=>
      @search @$search.val() if e.keyCode == ENTER_KEY

    ###########################
    # INIT
    ###########################

    setTimeout =>
      @$search_container.velocity
        translateY: [ 0, -20 ]
        opacity: [ 1, 0 ]
      , DUR * 2
    , DUR * 2

getInstance = ->
  if !instance
    instance = new Search()
  return instance

module.exports = getInstance
