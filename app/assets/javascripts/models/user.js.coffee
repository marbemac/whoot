class Whoot.Models.User extends Backbone.Model
  url: '/api/v2/users'

  initialize: ->

  parse: (resp, xhr) ->
    Whoot.App.Users.findOrCreate(resp.id, resp)

  following: (model) ->
    _.include(@get('following_users'), model.get('id'))

  pinged: (model) ->
    if model.get('pings_today')
      _.include(model.get('pings_today'), @get('id'))
    else
      false

  fullname: ->
    "#{@get('first_name')} #{@get('last_name')}"