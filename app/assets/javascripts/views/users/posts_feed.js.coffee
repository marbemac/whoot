class Whoot.Views.PostsFeed extends Backbone.View
  template: JST['posts/feed']
  tagName: 'section'
  id: 'posts-feed'

  initialize: ->
    @collection.on('reset', @render)
    @location_organized = {}

  render: =>
    $(@el).html(@template())
    @postsContainer = $(@el).find('.posts')
    $('#wrapper .content').addClass('on').html(@el)

    for post in @collection.models
      @addPost(post)

    @

  addLocation: (id, name) =>
    view = new Whoot.Views.PostsFeedLocation()
    view.id = id
    view.name = name
    console.log @postsContainer
    @postsContainer.append(view.render().el)
    @location_organized[id] = view

  addPost: (post) =>
    unless @location_organized[post.get('location')._id]
      @addLocation(post.get('location')._id, "#{post.get('location').city}, #{post.get('location').state_code}")

    @location_organized[post.get('location')._id].appendPost(post)
