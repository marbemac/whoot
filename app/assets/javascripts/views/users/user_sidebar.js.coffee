class Whoot.Views.UserSidebar extends Backbone.View
  el: $('.sidebar')

  initialize: ->

  render: ->
    $(@el).addClass('user-sidebar on')

    user_nav = new Whoot.Views.UserSidebarNav(model: @model, page: @page)
    $(@el).append(user_nav.render().el)

    static = new Whoot.Views.SidebarStatic(page: @page)
    $(@el).append(static.render().el)

    @