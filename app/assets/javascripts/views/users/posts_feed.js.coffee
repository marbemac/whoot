class Whoot.Views.PostsFeed extends Backbone.View
  id: 'posts-feed'

  initialize: ->
    @collection.on('reset', @render)
    @location_organized = {}

  render: =>
    for post in @collection.models
      @addPost(post)
    @

  addLocation: (id, name) =>
    view = new Whoot.Views.PostsFeedLocation()
    view.id = id
    view.name = name

    $(@el).append(view.render().el)
    @location_organized[id] = view

  addPost: (post) =>
    unless @location_organized[post.get('location')._id]
      @addLocation(post.get('location')._id, "#{post.get('location').city}, #{post.get('location').state_code}")

    @location_organized[post.get('location')._id].appendPost(post)