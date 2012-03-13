class Whoot.Collections.Users extends Backbone.Collection
  model: Whoot.Models.User

  findOrCreate: (id, data=null) ->
    model = @get(id)

    return model if model

    model = new Whoot.Models.User(data) unless model

    unless model
      model = new LL.Models.Post
      model.fetch({data: {id: id}})

    @add(model)

    model