class Whoot.Collections.UserActivity extends Backbone.Collection
  model: Whoot.Models.Post
  url: '/api/v2/users/activity'