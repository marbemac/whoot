class Whoot.Collections.UserFollowingUsers extends Backbone.Collection
  model: Whoot.Models.User
  url: =>
    "/api/v2/users/#{@id}/following_users"