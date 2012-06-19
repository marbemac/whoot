class Whoot.Views.PostsFeed extends Backbone.View
  id: 'posts-feed'

  initialize: ->
    @collection.on('reset', @render)
    @locations = []

  render: =>
    for item in @collection.models
      @addLocation(item.get('location'))
      for post in item.get('posts')
        @addPost(post)

    @resetPostCount()

    @

  addLocation: (location) =>
    view = new Whoot.Views.PostsFeedLocation()
    view.id = location._id
    view.name = location.city

    location = {
      id: location._id
      view: view
    }

    $(@el).append(location.view.render().el)

    @locations.push location

  findLocation: (id) =>
    _.find(@locations, (location) -> location.id == id)

  addPost: (post) =>
    @findLocation(post.get('location')._id).view.appendPost(post)

  resetPostCount: =>
    $('.posts-sidebar .btn[data-type="big_out"] div').text($('ul.big_out > li').length)
    $('.posts-sidebar .btn[data-type="low_out"] div').text($('ul.low_out > li').length)
    $('.posts-sidebar .btn[data-type="low_in"] div').text($('ul.low_in > li').length)
    $('.posts-sidebar .btn[data-type="working"] div').text($('ul.working > li').length)