class Whoot.Collections.UserFollowers extends Backbone.Collection
  model: Whoot.Models.User
  url: =>
    "/api/v2/users/#{@id}/followers"