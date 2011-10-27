jQuery ->

  $('.growfield').livequery ->
      $(@).growfield()

  # Clears a form or form element
  $.fn.clearForm = () ->
    this.each ->
      type = this.type
      tag = this.tagName.toLowerCase()
      if (tag == 'form')
        return $(':input',this).clearForm()
      if (type == 'text' || type == 'password' || tag == 'textarea')
        this.value = ''
      else if (type == 'checkbox' || type == 'radio')
        this.checked = false
      else if (tag == 'select')
        this.selectedIndex = -1

  # Sets the cursor to a position in an input
  $.fn.selectRange = (start, end) ->
    return @each ->
      if @setSelectionRange
        @focus()
        @setSelectionRange start, end
      else if @createTextRange
        range = @createTextRange()
        range.collapse true
        range.moveEnd 'character', end
        range.moveStart 'character', start
        range.select()

  # Automatic toggling of overlay label on inputs
  $('.lClear > input, .lClear > textarea').livequery ->
    $(@).attr 'autocomplete', 'off'

  $('.lClear label').livequery ->
    $(@).inFieldLabels({ fadeDuration: 100 })

  # Automatic clearing of help text in inputs
  $('.iclear').live 'focus', (e) ->
    self = $(@)
    if !self.hasClass('cleared') && !self.data('default') || self.val() == self.data('default')
      self.addClass('active').data('default', self.val()).selectRange(0, 0)

  $('.iclear').live 'blur', (e) ->
    self = $(@)
    if !$.trim(self.val()) || self.val() == self.data('default')
      self.removeClass('active cleared').val(self.data('default'))

  $('.iclear').live 'keydown', (e) ->
    self = $(@)
    if self.val() == self.data('default')
      self.removeClass('active').val('')

  $('.iclear').live 'keyup', (e) ->
    self = $(@)
    if !$.trim(self.val())
      self.addClass('active').val(self.data('default')).selectRange(0, 0)