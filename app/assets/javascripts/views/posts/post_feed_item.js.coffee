class Whoot.Views.PostFeedItem extends Backbone.View
  template: JST['posts/feed_item']
  tagName: 'li'
  className: 'odd'

  initialize: ->

  render: =>
    $(@el).html(@template(post: @model))

    @