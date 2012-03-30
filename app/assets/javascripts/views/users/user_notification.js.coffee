class Whoot.Views.UserNotification extends Backbone.View
  template: JST['users/notification']
  tagName: 'li'

  initialize: ->

  render: =>
    $(@el).html(@template(notification: @model))

    if @model.get('read') == false
      $(@el).addClass('unread')

    @