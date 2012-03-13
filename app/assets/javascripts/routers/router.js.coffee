class Whoot.Router extends Backbone.Router
  routes:
    'posts/new': 'postNew'
    '': 'postsFeed'

  initialize: ->
    @bind 'all', @_trackPageview

  #######
  # USERS
  #######

  postsFeed: ->
    return unless Whoot.App.current_user

    sidebar = new Whoot.Views.UserSidebar(model: Whoot.App.current_user)
    sidebar.page = 'user_feed'
    sidebar.render()

    feed = new Whoot.Views.PostsFeed(collection: Whoot.App.PostsFeed)
    feed.render()

    Whoot.App.PostsFeed.fetch()

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