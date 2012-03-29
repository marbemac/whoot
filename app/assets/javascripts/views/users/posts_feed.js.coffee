class Whoot.Views.PostsFeed extends Backbone.View
  id: 'posts-feed'

  events:
    'click li .top': 'toggleDetails'

  initialize: ->
    @collection.on('reset', @render)
    @location_organized = []

  render: =>
    for post in @collection.models
      @addPost(post)

    @organizeLocations()

    @

  organizeLocations: =>
    organized = []

    myLocation = _.find(@location_organized, (location) -> location.id == Whoot.App.current_user.get('location')._id)
    if myLocation
      $(@el).prepend(myLocation.view.el)

    me = _.find(@location_organized, (location) -> location.id == Whoot.App.current_user.get('id'))
    if me
      $(@el).prepend(me.view.el)

  addLocation: (id, name) =>
    view = new Whoot.Views.PostsFeedLocation()
    view.id = id
    view.name = name

    location = {
      id: id
      view: view
    }

    $(@el).append(location.view.render().el)

    @location_organized.push location

  findLocation: (id) =>
    _.find(@location_organized, (location) -> location.id == id)

  addPost: (post) =>
    return unless post.get('location')

    if post.get('user').id == Whoot.App.current_user.id
      @addLocation(Whoot.App.current_user.id, "My Post")
      id = Whoot.App.current_user.id
    else
      id = post.get('location')._id
      unless @findLocation(post.get('location')._id)
        @addLocation(post.get('location')._id, "#{post.get('location').city}, #{post.get('location').state_code}")

    @findLocation(id).view.appendPost(post)

  resetPostCount: =>
    $('.posts-sidebar .btn[data-type="big_out"] div').text($('ul.big_out li').length)
    $('.posts-sidebar .btn[data-type="low_out"] div').text($('ul.low_out li').length)
    $('.posts-sidebar .btn[data-type="low_in"] div').text($('ul.low_in li').length)
    $('.posts-sidebar .btn[data-type="working"] div').text($('ul.working li').length)

  toggleDetails: (e) ->
    target = $(e.target)

    if target.is('a') || target.hasClass('icon')
      return

    $(e.currentTarget).parent().toggleClass('on').find('.details').slideToggle(200)