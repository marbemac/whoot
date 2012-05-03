class Whoot.Views.BlockedUser extends Backbone.View
  template: JST['users/blocked_user']
  tagName: 'li'

  events:
    "click .btn": "unblockUser"

  render: =>
    $(@el).html(@template(user: @model))

    @

  unblockUser: (e) =>
    self = @

    $.ajax
      url: '/api/v2/users/blocked'
      dataType: 'json'
      type: 'delete'
      data: { id: @model.get('id') }
      beforeSend: ->
        $(self.el).find('.btn-success').addClass('disabled').text('Submitting...')
      success: (data) ->
        $(self.el).find('.btn-success').removeClass('disabled').text('Unblock User')
        $(self).remove()
      error: (jqXHR, textStatus, errorThrown) ->
        $(self.el).find('.btn-success').removeClass('disabled').text('Unblock User')
        globalError(textStatus, $(self.el))
      complete: ->
        $(self.el).find('.btn-success').removeClass('disabled').text('Unblock User')