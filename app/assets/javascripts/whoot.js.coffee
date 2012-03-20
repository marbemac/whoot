# hack because facebook login appends stupid things to the url
if window.location.hash == '#_=_'
  window.location = '/'

window.Whoot =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    @App =  new Whoot.Views.App()

    @Router = new Whoot.Router()
    Backbone.history.start(pushState: true)

jQuery ->

  # Start up Backbone
  Whoot.init()

  # Bootstrap tooltips
  $('[rel="tooltip"]').tooltip()

  # Global success function
  window.globalSuccess = (data, target=null) ->

    if data.flash
      createGrowl false, data.flash, 'Ok', 'green'

    if data.redirect
      window.location = data.redirect

  window.globalError = (jqXHR, target=null) ->
    data = $.parseJSON(jqXHR.responseText)

    if data.flash
      createGrowl false, data.flash, 'Error', 'red'

    switch jqXHR.status
      when 422
        if target && data && data.errors
          target.find('.alert-error').remove()
          errors_container = $('<div/>').addClass('alert alert-error').prepend('<a class="close" data-dismiss="alert">x</a>')
          for key,errors of data.errors
            if errors instanceof Array
              for error in errors
                errors_container.append("<div>#{error}</div>")
            else
              errors_container.append("<div>#{errors}</div>")
          target.find('.errors').prepend(errors_container)

  # Use gritter to create 'growl' notifications.
  # @param bool persistent Are the growl notifications persistent or do they fade after time?
  window.createGrowl = (persistent, content, title, theme) ->
    $.gritter.add
      # (string | mandatory) the heading of the notification
      title: title
      # (string | mandatory) the text inside the notification
      text: content
      # (string | optional) the image to display on the left
      image: false
      # (bool | optional) if you want it to fade out on its own or just sit there
      sticky: false
      # (int | optional) the time you want it to be alive for before fading out (milliseconds)
      time: 8000
      # (string | optional) the class name you want to apply directly to the notification for custom styling
      class_name: 'gritter-'+theme
      # (function | optional) function called before it opens
      before_open: ->
      # (function | optional) function called after it opens
      after_open: (e) ->
      # (function | optional) function called before it closes
      before_close: (e, manual_close) ->
        # the manual_close param determined if they closed it by clicking the "x"
      # (function | optional) function called after it closes
      after_close: ->

  # show the hidden login form on ctrl+L
  $(document).keypress (e) ->
    $code = if e.which then e.which else e.keyCode
    if e.ctrlKey && ($code == 108 || $code == 12)
      $('#auth-login').fadeToggle(300)
      return false
    else if e.ctrlKey && ($code == 99 || $code == 3)
      $('#auth-register').fadeToggle(300)
      return false
    else if e.ctrlKey && ($code == 101 || $code == 5)
      window.location = document.URL + '?_switch_user=_exit'