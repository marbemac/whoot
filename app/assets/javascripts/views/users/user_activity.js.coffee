class Whoot.Views.UserActivity extends Backbone.View
  template: JST['users/activity']
  tagName: 'section'
  className: 'user-actvity'

  initialize: ->

  render: =>
    $(@el).html(@template())

    @