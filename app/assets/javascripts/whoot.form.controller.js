// Wait for Document
$(function() {

  $('form.ajax').live('submit', function(event) {
    // Ajaxify this form

    event.preventDefault();
    $currentTarget = $(this);
    formSubmit($(this), null, null);

    return false;
  });

  /*
   * Submit and handle a form..
   */
  var formSubmit = function(form, success, error) {

    $.ajax({
      type: 'POST',
      url: form.attr('action'),
      data: form.serializeArray(),
      dataType: 'json',
      beforeSend: function() {
        console.log('Form submit');
        form.find('input, textarea').attr('disabled', true);
        form.find('.errors').html('').hide();
        $('#form-submitting').fadeIn(300);
      },
      success: function(data) {
        $('#form-submitting').fadeOut(300);
        form.find('input, textarea').removeAttr('disabled');
        form.find('input:not([type="submit"]), textarea').val('');
        if (appUpdate(data)) {
          if (data.result == 'error') {
            form.replaceWith(data.form);
          }
        }

        if (success) {
          success();
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log(jqXHR)

        $('#form-submitting').fadeOut(300);
        form.find('input, textarea').removeAttr('disabled');

        // If they need to login
        if (jqXHR.status == 401) {
          $('#login').click()
          $('#user_email').focus()
          $('.qtip.ui-tooltip').qtip('hide')
        }
        // If there was a form error
        else if (jqXHR.status == 422) {
          var $error_field = form.find('.errors');
          $error_field.show();
          errors = $.parseJSON(jqXHR.responseText)
          $.each(errors, function(target_field, field_errors) {
            $.each(field_errors, function(i, error) {
              $error_field.append('<div class="error">' + error + '</div>');
            })
          })
        }

        if (error) {
          error();
        }

        $.colorbox.resize();

      }
    });

  }; // end onStateChange

}); // end onDomLoad