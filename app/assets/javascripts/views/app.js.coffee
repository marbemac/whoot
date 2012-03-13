class Whoot.Views.App extends Backbone.View
  el: $('body')

  initialize: ->
    self = @

    # set the global collections
    @Users = new Whoot.Collections.Users

    @Posts = new Whoot.Collections.Posts
    @PostsFeed = new Whoot.Collections.PostsFeed

    # Pusher subscription tracking
    @subscriptions = {}
    @event_subscriptions = {}

    # set the current user
    @current_user = if $('#me').length > 0 then @Users.findOrCreate($('#me').data('user').id, $('#me').data('user')) else null

  # HANDLE PUSHER SUBSCRIPTIONS
  get_subscription: (id) =>
    @subscriptions[id]

  subscribe: (id) =>
    @subscriptions[id] = pusher.subscribe(id)

  get_event_subscription: (id, event) =>
    @event_subscriptions["#{id}_#{event}"]

  subscribe_event: (id, event) =>
    @event_subscriptions["#{id}_#{event}"] = true