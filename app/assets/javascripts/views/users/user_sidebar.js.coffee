class Whoot.Views.UserSidebar extends Backbone.View
  el: $('.sidebar')

  events:
    'click .notifications': 'showNotifications'

  initialize: ->
    @notifications = null
    Whoot.App.current_user.bind('change:unread_notification_count', @updateNotificationCount)

  render: ->
    $(@el).addClass('user-sidebar on')

    user_nav = new Whoot.Views.UserSidebarNav(model: @model, page: @page)
    $(@el).append(user_nav.render().el)

    sidebar = new Whoot.Views.SidebarStatic(page: @page)
    $(@el).append(sidebar.render().el)

    self = @

    # listen for notifications
    channel = Whoot.App.get_subscription("#{self.model.get('id')}_private")
    unless Whoot.App.get_event_subscription("#{self.model.get('id')}_private", 'new_notification')
      channel.bind 'new_notification', (data) ->
        self.model.set('unread_notification_count', self.model.get('unread_notification_count') + 1)
        if self.notifications
          notification = self.notifications.collection.findOrCreate(data.id, new Whoot.Models.Notification(data))
        createGrowl(false, data.full_text, 'Notification', 'green')

      Whoot.App.subscribe_event("#{self.model.get('id')}_private", 'new_notification')

    @

  showNotifications: =>
    if @notifications
      @notifications.togglePanel()
    else
      collection = Whoot.App.Notifications
      @notifications = new Whoot.Views.UserNotifications(collection: collection)
      collection.fetch()

  updateNotificationCount: =>
    $(@el).find('.notifications span').text(@model.get('unread_notification_count'))