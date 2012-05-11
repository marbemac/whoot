class Whoot.Views.MyFeed extends Backbone.View
  tagName: 'section'
  id: 'my-feed'

  events:
    'click #posts-feed-btn': 'renderPosts'
    'click #map-feed-btn': 'renderMap'
    'click #undecided-feed-btn': 'renderUndecided'
    'click #update-post': 'updatePost'
    'click #shout': 'shout'

  initialize: ->
    @feed = null
    @postsLoaded = false
    @undecidedLoaded = false

  render: =>
    @sidebar = new Whoot.Views.PostFeedSidebar()
    $(@el).append(@sidebar.render().el)

    @renderPosts()
    @

  renderPosts: =>
    @menuOff()
    $('#posts-feed-btn').addClass('on')
    if @postsLoaded
      $('#posts-feed').show()
    else
      @feed = new Whoot.Views.PostsFeed(collection: Whoot.App.PostsFeed)
      $(@el).append(@feed.render().el)
      @postsLoaded = true
      Whoot.App.PostsFeed.fetch()

    $('.posts-sidebar').show()

  renderMap: =>
    @menuOff()
    $('#map-feed-btn').addClass('on')
    if @map
      $(@map.el).show()
    else
      @map = new Whoot.Views.PostMap(collection: @feed)
      $('#posts-feed').after(@map.render().el)
      @map.buildMap()

    $('.map-sidebar').show()

  renderUndecided: =>
    @menuOff()
    $('#undecided-feed-btn').addClass('on')
    if @undecidedLoaded
      $('.user-list').show()
    else
      users = new Whoot.Collections.UserUndecided()
      list = new Whoot.Views.UserList(collection: users)
      $(@el).append(list.render().el)
      @undecidedLoaded = true
      users.fetch()

  menuOff: =>
    $('#posts-feed-btn, #undecided-feed-btn, #map-feed-btn').removeClass('on')
    $('#posts-feed, .user-list, #post-map, .posts-sidebar, .map-sidebar').hide()

  updatePost: =>
    form = new Whoot.Views.PostForm(model: Whoot.App.current_user)
    form.header = 'Update Your Post'
    form.buttonText = 'Update'
    form.modal = true
    form.render()

  shout: =>
    form = new Whoot.Views.ShoutForm(model: Whoot.App.current_user)
    form.render()