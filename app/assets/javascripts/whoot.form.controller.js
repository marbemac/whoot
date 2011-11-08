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
        if (!data.redirect && !data.reload)
        {
          $('#form-submitting').fadeOut(300);
        }

        form.find('input, textarea').removeAttr('disabled');

        appUpdate(data);

        if (success) {
          success();
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        $('#form-submitting').fadeOut(300);

        // If they need to login
        if (jqXHR.status == 401) {
          form.find('input, textarea').removeAttr('disabled');
          $('#login').click()
          $('#user_email').focus()
          $('.qtip.ui-tooltip').qtip('hide')
        }
        // If there was a form error
        else if (jqXHR.status == 422) {
          form.find('input, textarea').removeAttr('disabled');
          var $error_field = form.find('.errors');
          $error_field.show();
          var data = $.parseJSON(jqXHR.responseText)
          $.each(data.errors, function(target_field, field_errors) {
            $.each(field_errors, function(i, error) {
              $error_field.append('<div class="error">' + error + '</div>');
            })
          })
        }
        else if (jqXHR.status == 500) {
          createGrowl(false, 'Hmm... there was an unknown error. We\'re on it! If it continues to happen please email us.', 'Error', 'red');
        }

        if (error) {
          error();
        }

        $.colorbox.resize();

      }
    });

  }; // end onStateChange

}); // end onDomLoad