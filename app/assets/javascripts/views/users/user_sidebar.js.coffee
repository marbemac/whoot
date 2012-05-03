class Whoot.Views.UserSidebar extends Backbone.View
  el: $('.sidebar')

  events:
    'click .notifications': 'showNotifications'

  initialize: ->
    @notifications = null

  render: ->
    $(@el).addClass('user-sidebar on')

    user_nav = new Whoot.Views.UserSidebarNav(model: @model, page: @page)
    $(@el).append(user_nav.render().el)

    sidebar = new Whoot.Views.SidebarStatic(page: @page)
    $(@el).append(sidebar.render().el)

    @

  showNotifications: =>
    if @notifications
      $(@notifications.el).toggle('slide', {direction:'right', easing: 'easeOutExpo'}, 500)
    else
      collection = Whoot.App.Notifications
      @notifications = new Whoot.Views.UserNotifications(collection: collection)
      collection.fetch()