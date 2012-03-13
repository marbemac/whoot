class Whoot.Models.Post extends Backbone.Model

  initialize: ->

  parse: (resp, xhr) ->
    Whoot.App.Posts.findOrCreate(resp.id, resp)