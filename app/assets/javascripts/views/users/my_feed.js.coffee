class Whoot.Views.MyFeed extends Backbone.View
  tagName: 'section'
  id: 'my-feed'

  initialize: ->

  render: =>
    sidebar = new Whoot.Views.PostFeedSidebar()
    $(@el).append(sidebar.render().el)

    feed = new Whoot.Views.PostsFeed(collection: Whoot.App.PostsFeed)
    $(@el).append(feed.render().el)

    Whoot.App.PostsFeed.fetch()

    @
