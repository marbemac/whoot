class Whoot.Views.Header extends Backbone.View
  el: $('body header')
  template: JST['header']

  initialize: ->
    # only show if the user is logged in
    if @model
      @render()

  render: =>
    $(@el).html(@template())