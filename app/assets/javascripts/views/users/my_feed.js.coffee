class Whoot.Views.MyFeed extends Backbone.View
  tagName: 'section'
  id: 'my-feed'

  events:
    'click #posts-feed-btn': 'renderPosts'
    'click #undecided-feed-btn': 'renderUndecided'
    'click #update-post': 'updatePost'

  initialize: ->
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
      feed = new Whoot.Views.PostsFeed(collection: Whoot.App.PostsFeed)
      $(@el).append(feed.render().el)
      @postsLoaded = true
      Whoot.App.PostsFeed.fetch()

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
    $('#posts-feed-btn, #undecided-feed-btn').removeClass('on')
    $('#posts-feed, .user-list').hide()

  updatePost: =>
