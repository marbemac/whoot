class Whoot.Views.PostMapInfoWindow extends Backbone.View
  template: JST['posts/map_info_window']
  className: 'post-map-info-window'

  initialize: ->

  render: =>
    $(@el).html(@template(venueData: @model))
    @