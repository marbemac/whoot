class Whoot.Views.UserSettings extends Backbone.View
  el: $('#user-settings')

  events:
    'click .radio-btn': 'updateRadioSetting'
    'change select': 'updateLocation'

  initialize: ->
    blocked_users = new Whoot.Collections.BlockedUsers()

    blocking = new Whoot.Views.UserBlocking(collection: blocked_users)
    $(@el).append(blocking.el)

    blocked_users.fetch()

  updateRadioSetting: (e) =>
    button = $(e.target)

    data = {}
    data[button.attr('name')] = button.data('value')

    unless button.hasClass('btn-info')
      $.ajax
        url: '/api/v2/users'
        type: 'put'
        dataType: 'json'
        data: data
        beforeSend: ->
          button.oneTime 500, 'loading', ->
            button.button('loading')
        complete: ->
          button.stopTime 'loading'
          button.button('reset')
          button.toggleClass('btn-info')
          button.siblings().removeClass('btn-info')

  updateLocation: (e) =>
    button = $(e.target)
    self = @

    $.ajax
      url: '/api/v2/users/location'
      type: 'put'
      dataType: 'json'
      data: { id: button.val() }
      success: (data) ->
        globalSuccess(data, $(self.el))
      error: (jqXHR, textStatus, errorThrown) ->
        globalError(jqXHR)