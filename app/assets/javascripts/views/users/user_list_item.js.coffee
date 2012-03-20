class Whoot.Views.UserListItem extends Backbone.View
  template: JST['users/list_item']
  tagName: 'li'

  initialize: ->

  render: =>
    $(@el).addClass('odd') if @odd
    $(@el).append(@template(user: @model))

    if Whoot.App.current_user != @model
      follow = new Whoot.Views.FollowButton(model: @model)
      $(@el).find('.follow-c').html(follow.render().el)

    @