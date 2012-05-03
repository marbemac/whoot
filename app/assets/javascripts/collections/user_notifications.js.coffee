class Whoot.Collections.UserNotifications extends Backbone.Collection
  url: '/api/v2/users/notifications'
  model: Whoot.Models.Notification

  findOrCreate: (id, data=null) ->
    model = @get(id)

    return model if model

    model = new Whoot.Models.Notification(data) unless model

    unless model
      model = new LL.Models.Notification
      model.fetch({data: {id: id}})

    @add(model)

    model