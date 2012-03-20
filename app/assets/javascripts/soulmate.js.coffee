$ = jQuery

class Query
  constructor: (@minLength) ->
    @value = ''
    @lastValue = ''
    @emptyValues = []

  getValue: ->
    @value

  setValue: (newValue) ->
    @lastValue = @value
    @value = newValue

  hasChanged: ->
    !(@value == @lastValue)

  markEmpty: ->
    @emptyValues.push( @value )

  willHaveResults: ->
    @_isValid() && !@_isEmpty()

  _isValid: ->
    @value.length >= @minLength

  # A value is empty if it starts with any of the values
  # in the emptyValues array.
  _isEmpty: ->
    for empty in @emptyValues
      return true if @value[0...empty.length] == empty
    return false

class Suggestion
  constructor: (index, @term, @data, @type) ->
    @id = "#{index}-soulmate-suggestion"
    @index = index

  select: (callback) ->
    callback( @term, @data, @type, @index, @id)

  focus: ->
    @element().addClass( 'focus' )

  blur: ->
    @element().removeClass( 'focus' )

  render: (callback) ->
    """
      <li id="#{@id}" class="soulmate-suggestion">
        #{callback( @term, @data, @type, @index, @id)}
      </li>
    """

  element: ->
    $('#' + @id)

class SuggestionCollection
  constructor: (@renderCallback, @selectCallback, @allowNew) ->
    @focusedIndex = -1
    @suggestions = []

  update: (results, query) ->
    @suggestions = []
    i = 0

    for type, typeResults of results

      # sort the results by term length
      typeResults = _.sortBy(typeResults, (result) -> result.term.length)

      # add the create a new topic option
      if @allowNew && type == 'topic'
        # check to see if there is an untyped topic with this name already
        found = false
        for result in typeResults
          break if result['data'] && result['data']['type'] # skip if it has a type
          found == true if query.toLowerCase() == result.term.toLowerCase()
          unless found || !result['aliases'] || result['aliases'].length == 0 # check aliases
            aliases = _.map(result.aliases, (alias) -> alias.toLowerCase()) # gather lower case versions
            found = true if _.include(aliases, query.toLowerCase())

        unless found
          @suggestions.push( new Suggestion(i, "Create a new topic: #{query}", {term: query, id: 0}, 'create') )
          i += 1

      for result in typeResults
        @suggestions.push( new Suggestion(i, result.term, result, type) )
        i += 1

  blurAll: ->
    @focusedIndex = -1
    suggestion.blur() for suggestion in @suggestions

  render: ->
    h = ''

    if @suggestions.length

      type = null

      for suggestion in @suggestions

        if suggestion.type != type

          h += @_renderTypeEnd( type ) unless type == null
          type = suggestion.type
          h += @_renderTypeStart()

        h += @_renderSuggestion( suggestion )

      h += @_renderTypeEnd( type )

    return h

  count: ->
    @suggestions.length

  focus: (i) ->
    if i < @count()
      @blurAll()

      if i < 0
        @focusedIndex = -1

      else
        @suggestions[i].focus()
        @focusedIndex = i

  focusElement: (element) ->
    index = parseInt( $(element).attr('id') )
    @focus( index )

  focusNext: ->
    @focus( @focusedIndex + 1 )

  focusPrevious: ->
    @focus( @focusedIndex - 1 )

  focusFirst: ->
    @focus( 0 )

  selectFocused: ->
    if @focusedIndex >= 0
      @suggestions[@focusedIndex].select( @selectCallback )

  allBlured: ->
    @focusedIndex == -1

  # PRIVATE

  _renderTypeStart: ->
    """
      <li class="soulmate-type-container">
        <ul class="soulmate-type-suggestions">
    """

  _renderTypeEnd: (type) ->
    """
        </ul>
        <div class="soulmate-type">#{type}</div>
      </li>
    """

  _renderSuggestion: (suggestion) ->
    suggestion.render( @renderCallback )

class Soulmate

  KEYCODES = {9: 'tab', 13: 'enter', 27: 'escape', 38: 'up', 40: 'down'}

  constructor: (@input, options) ->

    that = this

    {url, types, renderCallback, selectCallback, maxResults, minQueryLength, timeout, allowNew, selectFirst} = options

    @url              = url
    @types            = types
    @maxResults       = maxResults
    @allowNew         = allowNew || false
    @timeout          = timeout || 1500
    @selectFirst      = selectFirst || false

    @xhr              = null

    @suggestions      = new SuggestionCollection( renderCallback, selectCallback, allowNew )
    @query            = new Query( minQueryLength )

    if ($('ul#soulmate').length > 0)
      @container = $('ul#soulmate')
    else
      @container = $('<ul id="soulmate">').appendTo('body')
      @repositionContainer()

    @container.delegate('.soulmate-suggestion',
      mouseover: -> that.suggestions.focusElement( this )
      click: (event) ->
        event.preventDefault()
        that.suggestions.selectFocused()
        that.hideContainer()

        # Refocus the input field so it remains active after clicking a suggestion.
        that.input.focus()
    )

    @input.
      keydown( @handleKeydown ).
      keyup( @handleKeyup ).
      mouseover( ->
        that.suggestions.blurAll()
      )

  repositionContainer: ->
    left = @input.offset().left - 10

    if left + 400 > $(window).width()
      left -= (left + 400) - $(window).width()

    @container.css
      top: @input.offset().top + @input.height() + 15
      left: left

  handleKeydown: (event) =>
    killEvent = true

    switch KEYCODES[event.keyCode]

      when 'escape'
        @hideContainer()

      when 'tab'
        @suggestions.selectFocused()
        unless @container.is(':visible')
          killEvent = false

      when 'enter'
        @suggestions.selectFocused()
        @hideContainer()
        # Submit the form if no input is focused.
#        if @suggestions.allBlured()
#          killEvent = false

      when 'up'
        @suggestions.focusPrevious()

      when 'down'
        @suggestions.focusNext()

      else
        killEvent = false

    if killEvent
      event.stopImmediatePropagation()
      event.preventDefault()

  handleKeyup: (event) =>
    return if KEYCODES[event.keyCode] == 'enter' || KEYCODES[event.keyCode] == 'tab'

    @query.setValue( @input.val() )

    if @query.hasChanged()

      if @query.willHaveResults()

        @suggestions.blurAll()
        @fetchResults()

      else
        @hideContainer()

  hideContainer: ->
    @suggestions.blurAll()

    @container.hide()

    # Stop capturing any document click events.
    $(document).unbind('click.soulmate')

  showContainer: ->
    @repositionContainer()
    @container.show()
    @suggestions.focusFirst() if @selectFirst

    # Hide the container if the user clicks outside of it.
    $(document).bind('click.soulmate', (event) =>
      @hideContainer() unless @container.has( $(event.target) ).length
    )

  fetchResults: ->
    # Cancel any previous requests if there are any.
    @xhr.abort() if @xhr?

    @xhr = $.ajax({
      url: @url
      dataType: 'jsonp'
      timeout: @timeout
      cache: true
      data: {
        term: @query.getValue()
        types: @types
        limit: @maxResults
      }
      success: (data) =>
        @update( data.results )
    })

  update: (results) ->
    @suggestions.update(results, @query.getValue())

    if @suggestions.count() > 0
      @container.html( $(@suggestions.render()) )
      @showContainer()

    else
      @query.markEmpty()
      @hideContainer()

$.fn.soulmate = (options) ->
  new Soulmate($(this), options)
  return $(this)

window._test = {
  Query: Query
  Suggestion: Suggestion
  SuggestionCollection: SuggestionCollection
  Soulmate: Soulmate
}