class Whoot.Views.PostFeedItem extends Backbone.View
  template: JST['posts/feed_item']
  tagName: 'li'

  initialize: ->

  render: =>
    $(@el).html(@template(post: @model))

    loop_in = new Whoot.Views.LoopInButton(model: @model)
    $(@el).find('.top').append(loop_in.render().el)
    @
