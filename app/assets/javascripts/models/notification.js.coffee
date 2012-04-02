class Whoot.Models.Notification extends Backbone.Model
  url: '/api/v2/notifications'

  initialize: ->

  parse: (resp, xhr) ->
    Whoot.App.Notifications.findOrCreate(resp.id, resp)