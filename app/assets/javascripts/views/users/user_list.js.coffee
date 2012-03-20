class Whoot.Views.UserList extends Backbone.View
  template: JST['users/list']
  tagName: 'div'
  className: 'content-tile user-list'

  initialize: ->
    @collection.on('reset', @render)
    @collection.on('add', @appendUser)

    # Always start on page 1
    #@.page = 1

  render: =>
    $(@el).html(@template())
    $('#wrapper .content').html(@el).show()
    $(@el).find('section').prepend("<h2>#{@pageTitle}</h2>")

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