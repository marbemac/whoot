class Whoot.Collections.UserNotifications extends Backbone.Collection
  model: Whoot.Models.Notification
  url: =>
    "/api/v2/users/#{@id}/notifications"
  findOrCreate: (id, data=null) ->
    model = @get(id)

    return model if model

    model = new Whoot.Models.Notification(data) unless model

    unless model
      model = new LL.Models.Notification
      model.fetch({data: {id: id}})

    @add(model)

    model