class Whoot.Collections.UserFollowers extends Backbone.Collection
  url: '/api/v2/users/followers'
  model: Whoot.Models.User