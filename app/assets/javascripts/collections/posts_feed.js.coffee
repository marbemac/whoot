class Whoot.Collections.PostsFeed extends Backbone.Collection
  url: '/api/v2/posts/feed'

  parse: (response) ->
    results = []
    for item in response
      data = {
        location: item.location
        posts: []
      }
      for post in item.posts
        data.posts.push(new Whoot.Models.Post(post))
      results.push(data)

    results