class Whoot.Collections.UserFollowingUsers extends Backbone.Collection
  url: '/api/v2/users/following_users'
  model: Whoot.Models.User