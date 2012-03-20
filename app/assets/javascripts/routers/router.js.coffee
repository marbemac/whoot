class Whoot.Router extends Backbone.Router
  routes:
    'posts/new': 'postNew'
    ':id/followers': 'userFollowers'
    ':id/following': 'userFollowingUsers'
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

      feed = new Whoot.Views.PostsFeed(collection: Whoot.App.PostsFeed)
      screen['components'].push(feed)

      Whoot.App.renderScreen('user_feed', id)

      Whoot.App.PostsFeed.fetch()

  userFollowers: (id) ->
    user = Whoot.App.Users.findOrCreate(id, new Whoot.Models.User($('#this').data('this')))

    if Whoot.App.findScreen('user_followers', id)
      Whoot.App.showScreen('user_followers', id)
    else
      screen = Whoot.App.newScreen('user_followers', id)

      sidebar = Whoot.App.findSidebar('user', id)
      unless sidebar
        sidebar = Whoot.App.createSidebar('user', id, user)
      screen['sidebar'] = sidebar

      collection = new Whoot.Collections.UserFollowers()
      feed = new Whoot.Views.UserList(collection: collection, model: user)
      feed.pageTitle = "#{user.fullname()}'s Followers"
      screen['components'].push(feed)

      Whoot.App.renderScreen('user_followers', id)

      collection.id = id
      collection.page = 1
      collection.fetch({data: {id: id}})

  userFollowingUsers: (id) ->
    user = Whoot.App.Users.findOrCreate(id, new Whoot.Models.User($('#this').data('this')))

    if Whoot.App.findScreen('user_following_users', id)
      Whoot.App.showScreen('user_following_users', id)
    else
      screen = Whoot.App.newScreen('user_following_users', id)

      sidebar = Whoot.App.findSidebar('user', id)
      unless sidebar
        sidebar = Whoot.App.createSidebar('user', id, user)
      screen['sidebar'] = sidebar

      collection = new Whoot.Collections.UserFollowingUsers()
      feed = new Whoot.Views.UserList(collection: collection, model: user)
      feed.pageTitle = "Users #{user.fullname()} is Following"
      screen['components'].push(feed)

      Whoot.App.renderScreen('user_following_users', id)

      collection.id = id
      collection.page = 1
      collection.fetch({data: {id: id}})

  #######
  # POSTS
  #######

  postNew: ->
    form = new Whoot.Views.PostForm()
    form.header = 'Post First. No Freeloaders!'
    $('#wrapper').append(form.render().el)

  #######
  # MISC
  #######

  _trackPageview: ->
    url = Backbone.history.getFragment()
#    _gaq.push(['_trackPageview', "/#{url}"])

  splashPage: ->

  staticPage: (name) ->