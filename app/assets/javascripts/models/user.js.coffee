class Whoot.Models.User extends Backbone.Model
  url: '/api/users'

  initialize: ->

  parse: (resp, xhr) ->
    Whoot.App.Users.findOrCreate(resp.id, resp)

  following: (model) ->
    _.include(@get('following_users'), model.get('_id'))

  bucket: ->
    switch window.location.hostname
      when 'localhost'
        'http://development.img.p-li.me'
      else
        'http://img.p-li.me'

  image_url: (w, h, m, version='current') ->
    if @get('image_versions') == 0
      null
    else if @get('processing_image')
      "#{@bucket()}/users/#{@get('_id')}/#{version}/original.png"
    else
      "#{@bucket()}/users/#{@get('_id')}/#{version}/#{w}_#{h}_#{m}.png"