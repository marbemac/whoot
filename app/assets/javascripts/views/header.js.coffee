class Whoot.Views.Header extends Backbone.View
  el: $('body header')
  template: JST['header']

  initialize: ->
    # only show if the user is logged in
    if @model && @model.get('posted_today') == true
      @render()

  render: =>
    $(@el).html(@template())

    view = new Whoot.Views.UserSearchInput()
    $(@el).append(view.render().el)