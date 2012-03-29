class Whoot.Views.PingButton extends Backbone.View
  template: JST['buttons/ping']
  className: 'ping btn btn-warning'
  tagName: 'span'

  events:
    'click': 'updatePing'

  initialize: ->
    unless @model.get('pinged')
      @model.set('pinged', Whoot.App.current_user.pinged(@model))

    @model.bind('change:pinged', @render)

  render: =>
    $(@el).html(@template(model: @model))

    if @model.get('pinged')
      $(@el).addClass('disabled').removeClass('btn-warning')

    @

  updatePing: =>
    return if $(@el).hasClass('disabled')

    self = @

    options = {
      data: {id: @model.get('id')}
      dataType: 'json'
      beforeSend: ->
        $(self.el).addClass('disabled')
      success: (data) ->
        self.model.set('pinged', !self.model.get('pinged'))
      error: (jqXHR, textStatus, errorThrown) ->
        $(self.el).removeClass('disabled')
        globalError(jqXHR)
    }

    options['type'] = 'post'

    $.ajax '/api/v2/users/pings', options