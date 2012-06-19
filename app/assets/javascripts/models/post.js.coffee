class Whoot.Models.Post extends Backbone.Model

  initialize: ->
    @set('user', new Whoot.Models.User(@get('user')))

    loop_ins = []
    for u in @get('loop_ins')
      loop_ins.push(new Whoot.Models.User(u))

    @set('loop_ins', loop_ins)

  is_looped_in: ->
    _.any(@get('loop_ins'), (loop_in) ->
      loop_in.id == Whoot.App.current_user.get('id')
    )