class Whoot.Views.UserBlocking extends Backbone.View
  template: JST['users/blocking']
  tagName: 'section'
  className: 'blocking'

  events:
    "click form.btn-success": "blockUser"

  initialize: =>
    @collection.on('reset', @render)

  render: =>
    $(@el).html(@template())
    self = @

    $(@el).find('input:first').soulmate
      url:            '/autocomplete/search',
      types:          ['user'],
      minQueryLength: 2,
      maxResults:     10,
      allowNew:       false,
      selectFirst:    true,
      renderCallback: (term, data, type) ->
        term
      selectCallback: (term, data, type) ->
        $(self.el).find('input:first').val(term)
        $(self.el).find('.blocked_id').val(data.id)

    for user in @collection.models
      @appendBlockedUser(user)

    @

  blockUser: (e) =>
    $.ajax
      url: @collection.url
      dataType: 'json'
      type: 'post'
      data: { id: $(@el).find('.blocked_id').val() }
      beforeSend: ->
        $(self.el).find('.btn-success').addClass('disabled').text('Submitting...')
      success: (data) ->
        $(self.el).find('.btn-success').removeClass('disabled').text('Block User')
        self.destroyForm()
      error: (jqXHR, textStatus, errorThrown) ->
        $(self.el).find('.btn-success').removeClass('disabled').text('Block User')
        globalError(jqXHR, $(self.el))
      complete: ->
        $(self.el).find('.btn-success').removeClass('disabled').text('Block User')

  appendBlockedUser: (user) =>
    view = new Whoot.Views.BlockedUser(model: user)
    $(@el).find('ul').append(view.render().el)