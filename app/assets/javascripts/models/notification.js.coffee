class Whoot.Models.Notification extends Backbone.Model
  url: '/api/v2/notifications'

  initialize: ->
    if @get('triggered_by')
      @set('triggered_by', new Whoot.Models.User(@get('triggered_by')))