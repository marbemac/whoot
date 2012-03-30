class Whoot.Views.UserActivity extends Backbone.View
  template: JST['users/activity']
  tagName: 'section'
  id: 'posts-feed'

  initialize: ->
    @collection.on('reset', @render)
    @count = 0

  render: =>
    $(@el).html(@template())

#    if @collection.models.length == 0
#      post =

    for post,i in @collection.models
      @appendPost(post, i%2)

    @

  appendPost: (post, odd) =>
    view = new Whoot.Views.PostFeedItem(model: post)
    view.showDate = true

    if odd
      $(view.el).addClass('odd')

    $(@el).prepend(view.render().el)
    $(view.el).wrap($('<ul/>').addClass("#{post.get('night_type')} unstyled"))

    @