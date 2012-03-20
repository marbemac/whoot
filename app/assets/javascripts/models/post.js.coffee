class Whoot.Models.Post extends Backbone.Model

  initialize: ->
    @set('user', Whoot.App.Users.findOrCreate(@get('user').id, @get('user')))

  parse: (resp, xhr) ->
    Whoot.App.Posts.findOrCreate(resp.id, resp)