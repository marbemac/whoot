class Whoot.Router extends Backbone.Router
  routes:
    'posts/new': 'postNew'
    'settings': 'userSettings'
    'pages/:name': 'staticPage'
    ':id/followers': 'userFollowers'
    ':id/following': 'userFollowingUsers'
    ':id': 'userActivity'
    '': 'postsFeed'

  initialize: ->
    @bind 'all', @_trackPageview

  #######
  # USERS
  #######

  postsFeed: ->
    user = Whoot.App.current_user
    return unless user
    id = 0

    if Whoot.App.findScreen('user_feed', id)
      Whoot.App.showScreen('user_feed', id)
    else
      screen = Whoot.App.newScreen('user_feed', id)

      sidebar = Whoot.App.findSidebar('user', id)
      unless sidebar
        sidebar = Whoot.App.createSidebar('user', id, user)
      screen['sidebar'] = sidebar

      feed = new Whoot.Views.MyFeed()
      screen['components'].push(feed)

      Whoot.App.renderScreen('user_feed', id)

  userFollowers: (id) ->
    user = new Whoot.Models.User($('#this').data('this'))

    if Whoot.App.findScreen('user_followers', id)
      Whoot.App.showScreen('user_followers', id)
    else
      screen = Whoot.App.newScreen('user_followers', id)

      sidebar = Whoot.App.findSidebar('user', 0)
      unless sidebar
        sidebar = Whoot.App.createSidebar('user', 0, Whoot.App.current_user)
      screen['sidebar'] = sidebar

      head = new Whoot.Views.UserHeader(model: user)
      screen['components'].push(head)

      collection = new Whoot.Collections.UserFollowers()
      feed = new Whoot.Views.UserList(collection: collection, model: user)
      feed.pageTitle = "#{user.fullname()}'s Followers"
      screen['components'].push(feed)

      Whoot.App.renderScreen('user_followers', id)

      $(feed.el).wrap('<section />')

      collection.id = id
      collection.page = 1
      collection.fetch()

  userFollowingUsers: (id) ->
    user = new Whoot.Models.User($('#this').data('this'))

    if Whoot.App.findScreen('user_following_users', id)
      Whoot.App.showScreen('user_following_users', id)
    else
      screen = Whoot.App.newScreen('user_following_users', id)

      sidebar = Whoot.App.findSidebar('user', 0)
      unless sidebar
        sidebar = Whoot.App.createSidebar('user', 0, Whoot.App.current_user)
      screen['sidebar'] = sidebar

      head = new Whoot.Views.UserHeader(model: user)
      screen['components'].push(head)

      collection = new Whoot.Collections.UserFollowingUsers()
      feed = new Whoot.Views.UserList(collection: collection, model: user)
      feed.pageTitle = "Users #{user.fullname()} is Following"
      screen['components'].push(feed)

      Whoot.App.renderScreen('user_following_users', id)

      $(feed.el).wrap('<section />')

      collection.id = id
      collection.page = 1
      collection.fetch()

  userActivity: (id) ->
    user = new Whoot.Models.User($('#this').data('this'))

    if Whoot.App.findScreen('user_activity', id)
      Whoot.App.showScreen('user_activity', id)
    else
      screen = Whoot.App.newScreen('user_activity', id)

      sidebar = Whoot.App.findSidebar('user', 0)
      unless sidebar
        sidebar = Whoot.App.createSidebar('user', 0, Whoot.App.current_user)
      screen['sidebar'] = sidebar

      head = new Whoot.Views.UserHeader(model: user)
      screen['components'].push(head)

      collection = new Whoot.Collections.UserActivity()
      collection.id = id
      feed = new Whoot.Views.UserActivity(collection: collection, model: user)
      screen['components'].push(feed)
      collection.fetch()

      Whoot.App.renderScreen('user_activity', id)

  userSettings: ->
    user = Whoot.App.current_user

    if Whoot.App.findScreen('user_settings', 0)
      Whoot.App.showScreen('user_settings', 0)
    else
      screen = Whoot.App.newScreen('user_settings', 0)

      sidebar = Whoot.App.findSidebar('user', 0)
      unless sidebar
        sidebar = Whoot.App.createSidebar('user', 0, Whoot.App.current_user)
      screen['sidebar'] = sidebar

      Whoot.App.renderScreen('user_settings', 0)

      new Whoot.Views.UserSettings()
#      $(feed.el).wrap('<section />')

#      collection.id = id
#      collection.page = 1
#      collection.fetch({data: {id: id}})

  staticPage: (name) ->
    if Whoot.App.findScreen('static_page', 0)
      Whoot.App.showScreen('static_page', 0)
    else
      screen = Whoot.App.newScreen('static_page', 0)

      sidebar = Whoot.App.findSidebar('static', 0)
      unless sidebar
        sidebar = Whoot.App.createSidebar('static', 0, Whoot.App.current_user)
      sidebar.page = name
      screen['sidebar'] = sidebar

      Whoot.App.renderScreen('static_page', 0)

      Whoot.Header.render()

  #######
  # POSTS
  #######

  postNew: ->
    form = new Whoot.Views.PostForm(model: Whoot.App.current_user)
    form.header = 'Post First. No Freeloaders!'
    $('#wrapper').append(form.render().el)

  #######
  # MISC
  #######

  _trackPageview: ->
    url = Backbone.history.getFragment()
#    _gaq.push(['_trackPageview', "/#{url}"])

  splashPage: ->