class Whoot.Views.PostFeedSidebar extends Backbone.View
  template: JST['posts/feed_sidebar']
  id: 'feed-sidebar'

  events:
    'click .posts-sidebar .btn': 'togglePostType'

  initialize: ->

  render: ->
    $(@el).html(@template())

    @

  togglePostType: (e) =>
    $("ul.#{$(e.currentTarget).data('type')}").toggle 300
    $(e.currentTarget).toggleClass($(e.currentTarget).data('type'))