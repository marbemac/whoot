class Whoot.Views.PostsFeedLocation extends Backbone.View
  template: JST['posts/feed_location']
  tagName: 'div'
  className: 'post-feed-location'

  initialize: ->
    @big_out = []
    @low_out = []
    @low_in = []
    @working = []
    @count = 0

  render: =>
    $(@el).html(@template(name: @name))

    @

  appendPost: (post) =>
    target = $(@el).find(".#{post.get('night_type')}")
    view = new Whoot.Views.PostFeedItem(model: post)
    target.append(view.render().el)

    if @count % 2 == 0
      $(view.el).addClass('odd')

    @count += 1