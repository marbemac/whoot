class Whoot.Views.LoopInButton extends Backbone.View
  template: JST['buttons/loop_in']
  className: 'loop-in-btn'

  events:
    'click': 'updateLoopIn'

  initialize: ->
    unless @model.get('looped_in')
      @model.set('looped_in', @model.is_looped_in())

    @model.bind('change:looped_in', @render)

  render: =>
    $(@el).html(@template(model: @model))
    $(@el).addClass('mine disabled') if @model.get('user') == Whoot.App.current_user
    $(@el).addClass('disabled') if @model.get('looped_in') == true

    @

  updateLoopIn: =>
    console.log 'clicked'
    return if $(@el).hasClass('disabled')

    self = @

    options = {
      data: {id: @model.get('id')}
      dataType: 'json'
      beforeSend: ->
        $(self.el).addClass('disabled')
      success: (data) ->
        self.model.set('looped_in', !self.model.get('looped_in'))
      error: (jqXHR, textStatus, errorThrown) ->
        $(self.el).removeClass('disabled')
        globalError(jqXHR)
      complete: ->
        $(self.el).removeClass('disabled')
    }

    if @model.get('looped_in') == true
      options['type'] = 'delete'
    else
      options['type'] = 'post'

    $.ajax '/api/v2/posts/loop_ins', options

