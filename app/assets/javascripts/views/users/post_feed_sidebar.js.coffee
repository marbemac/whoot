class Whoot.Views.PostFeedSidebar extends Backbone.View
  template: JST['posts/feed_sidebar']
  id: 'feed-sidebar'

  initialize: ->

  render: ->
    $(@el).html(@template())