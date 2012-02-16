(function(window, undefined) {

  // Prepare Variables
  $ = window.jQuery,
          $body = $(document.body),
          $application = $('#application'),
          $pageHeader = $('#page_header'),
          $feedFilters = $('#feed-filters'),
          $pageSidebar1 = $('#page_sb1'),
          $pageSidebar2 = $('#page_sb2'),
          $pageSidebar3 = $('#page_sb3'),
          $pageContent = $('#page_content'),
          $sidebar = $('#sidebar'),
          $footer = $('#footer'),
          pageClicked = false,// Keeps track of wether a page link has been clicked.
          $currentTarget = null, // The current clicked element.
          pageGet = '',
          pageClick = '';

  // Function to capitalize first character of a string
  String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
  }

  /*
   * Performs various site wide updates.
   * @param object parms
   *
   * @return bool Returns true if no events stopped progress.
   */
  appUpdate = function(params) {
    // if there's an event, publish it!
    if (params.event) {
      console.log('Event: ' + params.event);
      amplify.publish(params.event, params);
    }

    // Is there a message to show?
    if (params.flash) {
      var theme = params.status == 'error' ? 'red' : 'green';
      createGrowl(false, params.flash.capitalize(), params.status.capitalize(), theme);
    }


    if (params.replace_target)
    {
      $(params.replace_target).html(params.content)
    }

    if (params.result) {
      // does the user have to login?
      if (params.result == 'login') {
        $('#login').click();

        return false;
      }
      else if (params.result == 'error') {
        return false;
      }
    }

    if (params.feed) {
      $('#post-feed').fadeOut(300, function() {
        $('#post-feed').html(params.feed).fadeIn(300);
      })
    }

    if (params.feedReload) {
      feedReload(params.feedReload);

      return false;
    }

    if (params.redirect) {
      createGrowl(true, 'Success! Redirecting...', 'Success', 'green');
      window.location = params.redirect;

      return false;
    }

    return true;
  }

  /*
   * Main site-wide action functions.
   */
  doAction = function(url, requestType, params, success, error) {
    try {
      params = JSON.parse(params)
    } catch (e) {}

    $.ajax({
      url: url,
      type: requestType,
      dataType: 'json',
      data: params,
      cache: false,
      success: function(data) {
        $currentTarget.data('processing', false);
        appUpdate(data);
        if (success) {
          success(params, data);
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        var data = JSON.parse(jqXHR.responseText)
        appUpdate(data);

        if (jqXHR.status == 401 && $('#login').length > 0)
        {
          $('#login').click()
          createGrowl(false, 'You need to be logged in to do that.', '', 'red');
        }
        else if (jqXHR.status == 500)
        {
          createGrowl(false, 'Woops! There was an error. We\'ve been notified and will look into it ASAP.', '', 'red');
        }

        if (error) {
          error(params, data);
        }
      }
    })
  };

  feedReload = function($url) {
    $.get($url, {}, function(html) {
      $('#post-feed').fadeOut(500, function() {
        $(this).html(html).fadeIn(500);
      })
    }, 'json')
  }

  /*
   * Show the sitewide loading animation.
   */
  showLoading = function() {
    $body.addClass('loading');
    $('#ajax-loading').fadeIn(200);
  }

  /*
   * Hide the sitewide loading animation.
   */
  hideLoading = function() {
    $body.removeClass('loading');
    $('#ajax-loading').fadeOut(200);
  }

  /*
   * Use gritter to create 'growl' notifications.
   *
   * @param bool persistent Are the growl notifications persistent or do they fade after time?
   */
  window.createGrowl = function(persistent, content, title, theme) {
    $.gritter.add({
      // (string | mandatory) the heading of the notification
      title: title,
      // (string | mandatory) the text inside the notification
      text: content,
      // (string | optional) the image to display on the left
      image: false,
      // (bool | optional) if you want it to fade out on its own or just sit there
      sticky: false,
      // (int | optional) the time you want it to be alive for before fading out (milliseconds)
      time: 8000,
      // (string | optional) the class name you want to apply directly to the notification for custom styling
      class_name: 'gritter-'+theme,
      // (function | optional) function called before it opens
      before_open: function(){
      },
      // (function | optional) function called after it opens
      after_open: function(e){
      },
      // (function | optional) function called before it closes
      before_close: function(e, manual_close){
        // the manual_close param determined if they closed it by clicking the "x"
      },
      // (function | optional) function called after it closes
      after_close: function(){
      }
    });
  };

  // Make it a window property so we can call it outside via updateGrowls() at any point
  window.updateGrowls = function() {
    // Loop over each jGrowl qTip
    var each = $('.qtip.jgrowl:not(:animated)');
    each.each(function(i) {
      var api = $(this).data('qtip');

      // Set the target option directly to prevent reposition() from being called twice.
      api.options.position.target = !i ? $(document.body) : each.eq(i - 1);
      api.set('position.at', (!i ? 'top' : 'bottom') + ' right');
    });
  };

  // Setup our timer function
  function timer(event) {
    var api = $(this).data('qtip'),
            lifespan = 5000; // 5 second lifespan

    // If persistent is set to true, don't do anything.
    if (api.get('show.persistent') === true) {
      return;
    }

    // Otherwise, start/clear the timer depending on event type
    clearTimeout(api.timer);
    if (event.type !== 'mouseover') {
      api.timer = setTimeout(api.hide, lifespan);
    }
  }

  // Utilise delegate so we don't have to rebind for every qTip!
  $(document).delegate('.qtip.jgrowl', 'mouseover mouseout', timer);

  // END GROWL

})(window);