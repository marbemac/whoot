class Whoot.Views.SidebarStatic extends Backbone.View
  template: JST['users/sidebar_static']
  tagName: 'section'
  className: 'sidebar-footer'

  initialize: ->

  render: ->
    $(@el).html(@template())

    @