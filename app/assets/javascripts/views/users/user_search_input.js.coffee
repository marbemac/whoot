class Whoot.Views.UserSearchInput extends Backbone.View
  template: JST['users/search_input']
  className: 'user-search'

  initialize: ->

  render: =>

    $(@el).html(@template())

    $(@el).find('input').soulmate
      url:            '/autocomplete/search',
      types:          ['user'],
      minQueryLength: 2,
      maxResults:     10,
      allowNew:       false,
      selectFirst:    true,
      renderCallback: (term, data, type) ->
        if _.include(Whoot.App.current_user.get('blocked_by'), data.id)
          null
        else
          term
      selectCallback: (term, data, type) ->
        window.location = "/#{data.id}"

    @