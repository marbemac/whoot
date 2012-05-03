class Whoot.Views.UserNotifications extends Backbone.View
  template: JST['users/notifications']
  id: 'user-notifications'

  events:
    'click .close': 'togglePanel'

  initialize: ->
    @collection.on('reset', @render)
    @collection.on('add', @prependNotification)
    @count = 0

  render: =>

    if ($('#user-notifications').length == 0)
      $(@el).html(@template())
      $('body').append($(@el))

    if @collection.models.length == 0
      $(@el).find('section').append("<div class='none'>Hmm, there's nothing to show here</div>")
    else
      for notification,i in @collection.models
        @appendNotification(notification)

    $(@el).show('slide', {direction:'right', easing: 'easeOutExpo'}, 500)

    @clearNotifications()

    self = @

    @

  appendNotification: (notification) =>
    view = new Whoot.Views.UserNotification(model: notification)
    $(@el).find('ul').append($(view.render().el).show())

  prependNotification: (notification) =>
    view = new Whoot.Views.UserNotification(model: notification)
    $(@el).find('ul').prepend(view.render().el)
    $(view.el).effect 'slide', {direction: 'left', mode: 'show'}, 500

  togglePanel: =>
    $(@el).toggle('slide', {direction:'right', easing: 'easeOutExpo'}, 500)

  clearNotifications: =>
    if Whoot.App.current_user.get('unread_notification_count') > 0
      $.ajax
        url: '/api/v2/users'
        type: 'put'
        dataType: 'json'
        data: {'unread_notification_count': 0}
        complete: ->
          Whoot.App.current_user.set('unread_notification_count', 0)