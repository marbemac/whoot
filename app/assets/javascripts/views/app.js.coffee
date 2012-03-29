class Whoot.Views.App extends Backbone.View
  el: $('body')

  initialize: ->
    self = @

    # set the global collections
    @Users = new Whoot.Collections.Users

    @Posts = new Whoot.Collections.Posts
    @PostsFeed = new Whoot.Collections.PostsFeed

    # The global screens & sidebars
    @screens = {}
    @sidebars = {}

    # Pusher subscription tracking
    @subscriptions = {}
    @event_subscriptions = {}

    # set the current user
    @current_user = if $('#me').length > 0 then @Users.findOrCreate($('#me').data('user').id, $('#me').data('user')) else null

  newScreen: (name, id) =>
    @screens["#{name}_#{id}"] = {
      'sidebar': null,
      'components': []
    }

  findScreen: (name, id) =>
    @screens["#{name}_#{id}"]

  findSidebar: (type, id) =>
    @sidebars["#{type}_#{id}"]

  createSidebar: (type, id, model) =>
    switch type
      when 'user'
        sidebar = new Whoot.Views.UserSidebar(model: model)
      when 'static'
        sidebar = new Whoot.Views.StaticPageSidebar()
    @sidebars["#{type}_#{id}"] = sidebar

  renderScreen: (name, id) =>
    screen = @screens["#{name}_#{id}"]

    if screen['sidebar']
      screen['sidebar'].page = name
      screen['sidebar'].render()
      $(screen['sidebar'].el).show()

    target = $('#wrapper .content').show()

    for component in screen['components']
      target.append(component.render().el)

  showScreen: (name, id) =>
    screen = @screens["#{name}_#{id}"]

    if screen['sidebar']
      $(screen['sidebar'].el).show()

    for component in screen['components']
      $(component.el).show()



  # HANDLE PUSHER SUBSCRIPTIONS
  get_subscription: (id) =>
    @subscriptions[id]

  subscribe: (id) =>
    @subscriptions[id] = pusher.subscribe(id)

  get_event_subscription: (id, event) =>
    @event_subscriptions["#{id}_#{event}"]

  subscribe_event: (id, event) =>
    @event_subscriptions["#{id}_#{event}"] = true