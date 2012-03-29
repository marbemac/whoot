class Whoot.Views.PostForm extends Backbone.View
  template: JST['posts/form']
  id: 'post-form'

  events:
      "submit form": "preventFormSubmission"
      "click .submit": "createPost"
      "click .cancel": "destroyForm"
      "click .btn-group .btn": "buttonColor"
      "change #post-form-venue": "checkVenueClear"

  initialize: ->
    @collection = new Whoot.Collections.Posts()

    @modal = false
    @initial_text = ''
    @header = 'Update Your Post'
    @buttonText = 'Submit Post'
    @placeholder_text = 'What do you want to talk about?'

  render: ->
    $(@el).html(@template(user: @model, header: @header, buttonText: @buttonText, initial_text: @initial_text, placeholder_text: @placeholder_text))

    # setTimeout to wait for the modal animation so that the autocomplete can position itself correctly
    self = @

    if @modal
      $(@el).addClass('modal fade')
      $(@el).modal()

    # Venue google autocomplete
    autocomplete = new google.maps.places.Autocomplete($(self.el).find('#post-form-venue').get()[0])
    google.maps.event.addListener autocomplete, 'place_changed', ->
      place = autocomplete.getPlace()
      $(self.el).find('#post-form-venue-address').val(place.formatted_address)
      if (place.name && ($.inArray('restaurant', place.types) > 0 || $.inArray('food', place.types) > 0 || $.inArray('establishment', place.types) > 0))
        $(self.el).find('#post-form-venue-name').val(place.name)

    @

  createPost: (e) ->
    console.log e
    e.preventDefault()

    attributes = {}
    attributes['night_type'] = if $(@el).find('.night-type.active').length > 0 then $(@el).find('.night-type.active').data('val') else ''
    attributes['tag'] = $(@el).find('#post-form-content').val()
    attributes['address_original'] = $(@el).find('#post-form-venue').val()
    attributes['venue_address'] = $(@el).find('#post-form-venue-address').val()
    attributes['venue_name'] = $(@el).find('#post-form-venue-name').val()
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

  buttonColor: (e) ->
    $(e.target).addClass($(e.target).data('val'))
    $(e.target).siblings().removeClass('big_out low_out low_in working')

  preventFormSubmission: (e) ->
    e.preventDefault()
    return false

  checkVenueClear: (e) =>
    if $.trim($(@el).find('#post-form-venue').val()) == ''
      $(@el).find('#post-form-venue-address,#post-form-venue-name').val('')