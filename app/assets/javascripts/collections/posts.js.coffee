class Whoot.Collections.Posts extends Backbone.Collection
  url: '/api/posts'
  model: Whoot.Models.Post

  findOrCreate: (id, data=null) ->
    model = @get(id)

    return model if model

    model = new Whoot.Models.Post(data) unless model

    unless model
      model = new LL.Models.Post
      model.fetch({data: {id: id}})

    @add(model)

    model