class Whoot.Views.PostEvent extends Backbone.View
  template: JST['posts/event']
  tagName: 'li'

  initialize: ->

  render: ->
    $(@el).html(@template(event: @model, post: @post))

    @