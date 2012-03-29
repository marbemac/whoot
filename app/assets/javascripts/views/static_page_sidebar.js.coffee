class Whoot.Views.StaticPageSidebar extends Backbone.View
  template: JST['static_sidebar']
  el: $('.sidebar')
  id: 'static-sidebar'

  initialize: ->

  render: =>
    $(@el).html(@template(page: @page))
    @