class Whoot.Models.Post extends Backbone.Model

  initialize: ->
    @set('user', Whoot.App.Users.findOrCreate(@get('user').id, @get('user')))

  parse: (resp, xhr) ->
    Whoot.App.Posts.findOrCreate(resp.id, resp)

  looped_in: ->
    _.any(@get('loop_ins'), (loop_in) ->
      loop_in._id == LL.App.current_user.get('id')
    )