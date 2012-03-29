class Whoot.Views.UserSettings extends Backbone.View
  el: $('#user-settings')

  events:
    'click .radio-btn': 'updateRadioSetting'
    'change select': 'updateLocation'

  initialize: ->

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

    console.log(e)

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
