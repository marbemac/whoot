class Whoot.Views.UserList extends Backbone.View
  template: JST['users/list']
  className: 'user-list'

  initialize: ->
    @collection.on('reset', @render)
    @collection.on('add', @appendUser)

    # Always start on page 1
    #@.page = 1

  render: =>
    $(@el).html(@template(title: @pageTitle))

    if @collection.models.length == 0
      $(@el).find('section').append("<div class='none'>Hmm, there's nothing to show here</div>")
    else
      for user,i in @collection.models
        @appendUser(user, i%2)

    @

  appendUser: (user, odd) =>
    view = new Whoot.Views.UserListItem(model: user)
    view.odd = odd
    $(@el).find('ul').append(view.render().el)

    @