class Whoot.Views.PostFeedItem extends Backbone.View
  template: JST['posts/feed_item']
  tagName: 'li'

  events:
    "keypress textarea": "createComment"

  initialize: ->
    self = @

    # Subscribe to pusher loop ins
    channel = Whoot.App.get_subscription(@model.get('user').get('id'))
    unless channel
      channel = Whoot.App.subscribe(@model.get('user').get('id'))

    unless Whoot.App.get_event_subscription(@model.get('user').get('id'), 'loop_in')
      channel.bind 'post_event', (data) ->
        console.log 'foo'
        if data.type == 'PostLoopEvent'
          user = Whoot.App.Users.findOrCreate(data.user.id, new Whoot.Models.User(data.user))
          self.appendLoopIn(user)
          self.model.set('votes', self.model.get('votes')+1)
          $(self.el).find('.votes').text(parseInt($(self.el).find('.votes').text()) + 1)

        else if data.type == 'PostCommentEvent'
          self.model.set('comment_count', self.model.get('comment_count')+1)
          $(self.el).find('.comments_count span').text(parseInt($(self.el).find('.comments_count span').text()) + 1)

        self.prependEvent(data)

      Whoot.App.subscribe_event(@model.get('user').get('id'), 'loop_in')

  render: =>
    $(@el).html(@template(post: @model))

    loop_in = new Whoot.Views.LoopInButton(model: @model)
    $(@el).find('.top').append(loop_in.render().el)

    for event in @model.get('events')
      @prependEvent(event)

    for user in @model.get('loop_ins')
      @appendLoopIn(user)

    @

  appendLoopIn: (user) =>
    $(@el).find('.right .none').remove()
    $(@el).find('.right').append($('<a/>').attr('href', "/#{user.get('id')}").text(user.fullname()))

  prependEvent: (event) =>
    view = new Whoot.Views.PostEvent(model: event)
    view.post = @model
    $(@el).find('.events').prepend(view.render().el)

  createComment: (e) =>
    if e.keyCode == 13 # enter
      e.preventDefault()

      content = $(@el).find('textarea').val()
      return if $.trim(content).length == 0

      self = @
      input = $(self.el).find('textarea')

      $.ajax
        url: '/api/v2/comments'
        dataType: 'json'
        type: 'POST'
        data: {content: content, post_id: self.model.get('id')}
        beforeSend: ->
          input.attr('disabled', 'disabled')
        success: (data) ->
          input.removeAttr('disabled').val('').blur()
          globalSuccess(data, input.parents('form:first'))
        error: (jqXHR, textStatus, errorThrown) ->
          input.removeAttr('disabled')
          globalError(jqXHR, input.parents('form:first'))
        complete: ->
          input.removeAttr('disabled')