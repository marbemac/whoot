class Whoot.Models.Notification extends Backbone.Model
  url: '/api/v2/notifications'

  initialize: ->
    if @get('triggered_by')
      @set('triggered_by', Whoot.App.Users.findOrCreate(@get('triggered_by').id, @get('triggered_by')))

  parse: (resp, xhr) ->
    Whoot.App.Notifications.findOrCreate(resp.id, resp)