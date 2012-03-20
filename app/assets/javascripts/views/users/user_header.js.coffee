class Whoot.Views.UserHeader extends Backbone.View
  template: JST['users/header']
  tagName: 'section'
  id: 'user-header'

  initialize: ->

  render: =>

    $(@el).html(@template(user: @model))

    if Whoot.App.current_user != @model
      follow = new Whoot.Views.FollowButton(model: @model)
      $(@el).find('.follow-c').html(follow.render().el)

    @