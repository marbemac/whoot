class Whoot.Views.PostsFeed extends Backbone.View
  id: 'posts-feed'

  events:
    'click li': 'toggleDetails'

  initialize: ->
    @collection.on('reset', @render)
    @location_organized = {}

  render: =>
    for post in @collection.models
      @addPost(post)

    @resetPostCount()

    @

  addLocation: (id, name) =>
    view = new Whoot.Views.PostsFeedLocation()
    view.id = id
    view.name = name

    $(@el).append(view.render().el)
    @location_organized[id] = view

  addPost: (post) =>
    return unless post.get('location')

    if post.get('user').id == Whoot.App.current_user.id
      @addLocation(Whoot.App.current_user.id, "My Post")
      id = Whoot.App.current_user.id
    else
      id = @location_organized[post.get('location')._id]
      unless @location_organized[post.get('location')._id]
        @addLocation(post.get('location')._id, "#{post.get('location').city}, #{post.get('location').state_code}")

    @location_organized[id].appendPost(post)

  resetPostCount: =>
    $('.posts-sidebar .btn[data-type="big_out"] div').text($('ul.big_out li').length)
    $('.posts-sidebar .btn[data-type="low_out"] div').text($('ul.low_out li').length)
    $('.posts-sidebar .btn[data-type="low_in"] div').text($('ul.low_in li').length)
    $('.posts-sidebar .btn[data-type="working"] div').text($('ul.working li').length)

  toggleDetails: (e) ->
    $(e.target).closest('li').toggleClass('on').find('.details').slideToggle(300)