class Whoot.Views.UserSidebarNav extends Backbone.View
  template: JST['users/sidebar_nav']
  tagName: 'section'

  initialize: ->

  render: ->
    $(@el).html(@template(user: @model))

    @