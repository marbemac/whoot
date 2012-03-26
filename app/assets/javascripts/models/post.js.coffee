class Whoot.Models.Post extends Backbone.Model

  initialize: ->
    @set('user', Whoot.App.Users.findOrCreate(@get('user').id, @get('user')))

    loop_ins = []
    for u in @get('loop_ins')
      loop_ins.push(Whoot.App.Users.findOrCreate(u.id, u)

    @set('loop_ins', loop_ins)

  parse: (resp, xhr) ->
    Whoot.App.Posts.findOrCreate(resp.id, resp)

  is_looped_in: ->
    _.any(@get('loop_ins'), (loop_in) ->
      loop_in.id == Whoot.App.current_user.get('id')
    )