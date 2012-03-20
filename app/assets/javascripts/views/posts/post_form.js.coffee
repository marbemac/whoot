class Whoot.Views.PostForm extends Backbone.View
  template: JST['posts/form']
  id: 'post-form'

  events:
      "submit form": "createPost"
      "click .cancel": "destroyForm"

  initialize: ->
    @collection = new Whoot.Collections.Posts()

    @modal = false
    @initial_text = ''
    @header = 'Update Your Post'
    @placeholder_text = 'What do you want to talk about?'

  render: ->
    $(@el).html(@template(header: @header, initial_text: @initial_text, placeholder_text: @placeholder_text))

    # setTimeout to wait for the modal animation so that the autocomplete can position itself correctly
    self = @

    if @modal
      $(@el).addClass('modal fade')
      $(@el).modal()

    @

  createPost: (e) ->
    e.preventDefault()

    attributes = {}
    attributes['night_type'] = if $(@el).find('.night-type.active').length > 0 then $(@el).find('.night-type.active').data('val') else ''
    attributes['tag'] = $(@el).find('#post-form-content').val()
    attributes['address_original'] = $(@el).find('#post-form-venue').val()
    attributes['suggest'] = if $(@el).find('.suggestions.active').length > 0 then true else false
    attributes['twitter'] = if $(@el).find('.twitter.active').length > 0 then true else false

    self = @

    $.ajax
      url: @collection.url
      dataType: 'json'
      type: 'POST'
      data: attributes
      beforeSend: ->
        $(self.el).find('.submit').button('loading')
      success: (data) ->
        $(self.el).find('.submit').button('reset')
        globalSuccess(data, $(self.el))
      error: (jqXHR, textStatus, errorThrown) ->
        $(self.el).find('.submit').button('reset')
        globalError(jqXHR, $(self.el))
      complete: ->
        $(self.el).find('.submit').button('reset')

  destroyForm: ->
    $(@el).modal('hide')