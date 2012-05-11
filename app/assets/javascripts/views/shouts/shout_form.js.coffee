class Whoot.Views.ShoutForm extends Backbone.View
  template: JST['shouts/form']
  id: 'shout-form'
  className: 'modal fade'

  events:
      "click .submit": "createShout"
      "click .cancel": "destroyForm"

  initialize: ->

  render: =>
    $(@el).html(@template(user: @model))

    # setTimeout to wait for the modal animation so that the autocomplete can position itself correctly
    self = @

    $(@el).modal()

    @

  createShout: (e) =>
    e.preventDefault()

    attributes = {}
    attributes['content'] = $(@el).find('#shout-content').val()

    self = @
    console.log attributes
    $.ajax
      url: '/api/v2/shouts'
      dataType: 'json'
      type: 'POST'
      data: attributes
      beforeSend: ->
        $(self.el).find('.submit').attr('disabled', 'disabled')
      success: (data) ->
        $(self.el).find('.submit').removeAttr('disabled')
        self.destroyForm()
        globalSuccess(data, $(self.el))
      error: (jqXHR, textStatus, errorThrown) ->
        $(self.el).find('.submit').removeAttr('disabled')
        globalError(jqXHR, $(self.el))
      complete: ->
        $(self.el).find('.submit').removeAttr('disabled')

  destroyForm: =>
    $(@el).modal('hide')