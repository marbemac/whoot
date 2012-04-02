class Whoot.Views.UserNotifications extends Backbone.View
  template: JST['users/notifications']
  id: 'user-notifications'

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

    @

  appendNotification: (notification) =>
    view = new Whoot.Views.UserNotification(model: notification)
    $(@el).find('ul').append(view.render().el)

  prependNotification: (notification) =>