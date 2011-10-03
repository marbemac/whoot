$(function() {

  /**
   * SPLASH PAGE
   */

  // show the hidden login form on ctrl+L
  $(document).keypress(function(e) {
    var $code = e.which ? e.which : e.keyCode;
    if (e.ctrlKey && ($code == 108 || $code == 12)) {
      $('#auth-login').fadeToggle(300);
      return false;
    }
    else if (e.ctrlKey && ($code == 99 || $code == 3)) {
      $('#auth-register').fadeToggle(300);
      return false;
    }
    else if (e.ctrlKey && ($code == 101 || $code == 5)) {
      window.location = document.URL + '?_switch_user=_exit';
    }
  })

//  if ($('#splash').length > 0)
//  {
//    $('#splash .info.one').oneTime(400, 'show', function() {
//      $(this).fadeIn(200);
//    })
//    $('#splash .info.two').oneTime(600, 'show', function() {
//      $(this).fadeIn(200);
//    })
//    $('#splash .info.three').oneTime(800, 'show', function() {
//      $(this).fadeIn(200);
//    })
//  }

  /**
   * USERS
   */

  $('.user-link').livequery(function() {
    $(this).each(function() {
      var $self = $(this);
      $self.qtip({
        content: {
          text: 'Loading...',
          ajax: {
            once: true,
            url: $self.data("d").tab,
            type: 'get',
            success: function(data) {
              $('.user-' + $self.data('d').id).qtip('option', {
                'content.text': data,
                'content.ajax': false
              });
            }
          }
        },
        style: {classes: 'ui-tooltip-shadow ui-tooltip-light', tip: true},
        position: {
          my: 'bottom center',
          at: 'top center',
          viewport: $(window)
        },
        show: {delay: 1000},
        hide: {delay: 300, fixed: true}
      })
    })
  })

  /*
   * POSTS
   */

  $('#declare-post').livequery(function() {
    $('#post-box').fadeIn(500);
  })

  $('#change-post').live('click', function() {
    $('#post-box').fadeIn(500);
  })

  // Show confirm button for cancel open invite post
  $('#cancel-post').livequery(function() {
    $(this).colorbox({transition: "none", opacity: .5, inline: true, href: "#invite-cancel-confirm"});
  })

  // Toggle collapse right undecided bar
  $('.undecidedC .side-toggle, #feed-filters .undecided').live('click', function() {
    $('.undecidedC').toggleClass('collapsed');
  })

  // Add qTips to the feed post stats
  $('#feed-stats div').qtip({
    content: {
      attr: 'title'
    },
    style: {
      classes: 'ui-tooltip-blue ui-tooltip-shadow ui-tooltip-rounded my-pings-tip'
    },
    position: {
      my: 'top center',
      at: 'bottom center'
    }
  })

  // Toggle new post options
  $('#post-box .type, #invite-page .type').live('click', function() {
    $(this).addClass('on').siblings('.type').removeClass('on');
    $(this).parent().find('.post_type').val($(this).data('val'));
  })

  // Scroll to my post
  $('#my-post:not(.invite)').live('click', function(ev) {
    if ($(ev.target).attr('id') == 'change-post' || $(ev.target).attr('id') == 'cancel-post')
      return;

    var $self = $(this);
    $.scrollTo($self.data('target'), {
      duration: 500,
      onAfter: function() {
        $($self.data('target')).click();
      }
    })
  })

  // Submit a new post
  var postSubmit = false;
  $('.post_create .submit').live('click', function() {
    if (postSubmit)
      return;

    postSubmit = true;
    var $self = $(this);
    var $error_flag = false;

    $('#post-box .status').removeClass('error');
    $self.text('Working...');

    var $payload = {};
    $payload[$('#whoot_post_form_type').attr('name')] = $('#whoot_post_form_type').val();
    $payload[$('#whoot_post_form_currentLocation').attr('name')] = $('#whoot_post_form_currentLocation').val();

    $tagCount = 0;
    $.each($('input.tag'), function() {
      if ($.trim($(this).val()).length > 0) {
        $tagCount++;
      }
      $payload[$(this).attr('name')] = $(this).val();
    })

    if ($.inArray($payload[$('#whoot_post_form_type').attr('name')], ['working', 'low_in', 'low_out', 'big_out']) == -1) {
      $error_flag = true;
      $('#post-box .status').addClass('error');
    }

    if ($tagCount == 0) {
      $error_flag = true;
      $('.post_create .errors').text('You must input 1 - 5 tags! Be sure to press enter after inputting them.');
    }

    if ($error_flag) {
      $self.text('Submit Post');
      postSubmit = false;
      return false;
    }

    $.post($('.post_create').attr('action'), $payload, function(data) {
      appUpdate(data);
      $self.text('Submit Post');
      postSubmit = false;
    }, 'json');
  })

  // Cancel a change post
  $('#post-box .cancel').live('click', function() {
    $('#post-box').fadeOut(300);
  })

  // Cancel a open invite cancellation
  $('#invite-cancel-confirm .cancel').live('click', function() {
    $('#invite-cancel-confirm').colorbox.close();
  })

  // Toggle the activity of a post
  var postActivityToggle = false;
  $('.teaser.post').live('click', function(ev) {
    if ($(ev.target).is('a') || $(ev.target).hasClass('tag trendable') || postActivityToggle)
      return;

    postActivityToggle = true;
    var $self = $(this);
    if ($self.next().hasClass('post-details')) {
      $self.toggleClass('on').next().toggle();
      postActivityToggle = false;

      return;
    }

    $.get($self.data('details'), {}, function(data) {
      $self.after(data.details).toggleClass('on');
      postActivityToggle = false;
    }, 'json')
  })

  $('#new_invite_post').live('keypress', function(e) {
    if (e.keyCode == 13) {
       return false;
    }
  })

  // Switch between normal post and open invite submission in the post box
  $('#post-box .nav .option').live('click', function() {
    $('#post-box form').hide();
    $($(this).data('target')).show();
    $(this).addClass('on').siblings().removeClass('on');
  })

  // Show the post-where places autocomplete
  $('#invite_post_venue_address').livequery(function() {
    var $self = $(this);
    var $auto = new google.maps.places.Autocomplete(document.getElementById('invite_post_venue_address'));

    // Handle a place choice
    google.maps.event.addListener($auto, 'place_changed', function() {
      var place = $auto.getPlace();
      $('#invite_post_venue_address').val(place.formatted_address);
      $('#invite_post_venue_coordinates').val(place.geometry.location.lng() + ' ' + place.geometry.location.lat());
    })
  })

  // Draw on post maps
  $('.invite-map').livequery(function() {
    var $self = $(this);

    var latlng = new google.maps.LatLng($self.data('lat'), $self.data('lon'));

    var myOptions = {
      zoom: 16,
      center: latlng,
      disableDefaultUI: true,
      scaleControls: true,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    var map = new google.maps.Map(document.getElementById($self.attr('id')),
            myOptions);

    var marker = new google.maps.Marker({
      position: latlng,
      map: map,
      title: $self.data('name')
    });
  })

  /*
   * COMMENTS
   */
  $('.comment_new .content').live('keypress', function(e) {
    if (e.keyCode == 13) {
      e.preventDefault();
      $(this).siblings('input[type="submit"]').click();
    }
  })

  /*
   * tagS
   */

  // Handle post tags
  // How many tags are we allowed?
  var $tagMax = 5;
  // How many characters per tag (avg)
  var $characterMax = 10;
  $('.post_create .tags').live('keypress', function(e) {
    var $code = e.which ? e.which : e.keyCode;
    $(this).siblings('.errors').text('');

    // Get the number of tags the user is trying to add
    $tagNum = $.trim($(this).val()).split(' ').length;

    // 13 enter keypress
    if ($code == 13) {
      e.preventDefault();
      // Calculate how many tags the user has already added
      $currenttags = '';
      $.each($('input.tag'), function() {
        if ($.trim($(this).val()).length > 0) {
          $currenttags += $(this).val() + ' ';
        }
      })

      if ($currenttags.replace(' ', '').length + $(this).val().replace(' ', '').length > $tagMax * $characterMax) {
        $(this).siblings('.error').text('Stop using such big tags. You may use a maximum of ' + $tagMax * $characterMax + ' characters for your 5 tags.');
      }
      else if ($.trim($currenttags).split(' ').length + $tagNum > $tagMax) {
        $(this).siblings('.errors').text('You cannot use more than ' + $tagMax + ' tags total.');
      }
      // Add the tag
      else {
        var target = $(this).siblings('.tagsC .tag:not(.on):first');
        target.addClass('on').prepend('<div>' + $(this).val() + '</div>');
        $(target.data('target')).val($(this).val());
        $(this).val('');
      }
      e.preventDefault();
    }
    else {
      // We only allow phrases of 4 or less tags...
      if (($tagNum > 4 || ($tagNum == 4 && $code == 32)) && $code != 8 && $code != 46) {
        e.preventDefault();
        $(this).siblings('.errors').text('You cannot use more than four words in a single phrase');
      }
    }
  })

  // Used to delete an already added tag (on the submit post form)
  $('.post_create .tag span').live('click', function() {
    $(this).siblings().remove();
    $($(this).parent().removeClass('on').data('target')).val('');
  })

  // Filter posts by tag
  $('.tag').live('click', function() {
    var $self = $(this);

    if ($('.tag-filters [data-id="' + $(this).data('id') + '"]').length == 0) {
      $('.tag-filters').show();

      $('.tag-filters').append($(this).clone().append('<span>x</span>'));
      $('.teaser').each(function() {
        if ($(this).find('.tag[data-id="' + $self.data('id') + '"]').length == 0) {
          $(this).parent().hide();
        }
      })
    }
  })

  // Remove a filtered tag
  $('.tag-filters .tag').live('click', function() {
    var $tag = $(this);

    var $filteredFound = false;
    var $filteredtags = '';
    $.each($('.tag-filters .tag'), function() {
      if ($(this).data('id') != $tag.data('id')) {
        $filteredFound = true;
        $filteredtags += '[data-id="' + $(this).data('id') + '"], ';
      }
    })

    if (!$filteredFound) {
      $('.teaser').parent().fadeIn(150);
    }
    else {
      console.log($filteredtags);
      $('.teaser').each(function() {
        if ($(this).find($filteredtags).length != 0) {
          $(this).parent().fadeIn(150);
        }
      })
    }
    $(this).remove();

    if ($('.tag-filters .tag').length == 0) {
      $('.tag-filters').hide();
    }
  })

  /*
   * LISTS
   */
  $("#list-add-user").autocomplete($('#list-add-user').data('url'), {
    minChars: 3,
    width: 143,
    matchContains: true,
    autoFill: false,
    searchKey: 'name',
    formatItem: function(row, i, max) {
      return row.name;
    },
    formatMatch: function(row, i, max) {
      return row.name;
    },
    formatResult: function(row) {
      return row.name;
    }
  });
  $("#list-add-user").result(function(event, data, formatted) {
    console.log(data);
    $.post($('#list-add-user').data('url-add'), {'userId': data.id}, function(data) {
      appUpdate(data);
      $('#list-add-user').val($('#list-add-user').data('default'));

      if (data.result != 'error') {
        $('.list-left ul').prepend('<li>' + data.user + '</li>');
        $('.list-left ul .none').remove();
      }
    }, 'json');
  });

  /*
   * PINGS
   */
  $('.ping-countdown').livequery(function() {
    var $self = $(this);
    $self.countdown({
      layout: '{sn}',
      until: '+' + $self.data('until') + 's',
      onExpiry: function() {
        console.log('test');
        $self.prev().replaceWith('<span class="pinged">Pinged</span>');
        $self.remove();
      }
    });
  })

  /*
   * MENUS
   */

  // Single choice menu.
  $('.sc-menu').live({
    mouseenter: function() {
      $(this).find('li').show();
    },
    mouseleave: function() {
      $(this).find('li:not(.on)').hide();
    }
  })
  $('.sc-menu a').live('click', function() {
    $(this).parent().addClass('on').siblings().removeClass('on');
  })

  // Multiple choice menu
  $('.mc-menu a').live('click', function() {
    $(this).parent().toggleClass('on');
  })

  /*
   * NOTIFICATIONS
   */
  $('#unread-notification-count').live('click', function(e) {
    if ($(this).find('#notificationsC').length > 0) {
      $(this).find('#notificationsC').toggle();
    }
    else {
      startAction($(this), 'GET', $(this).attr('href'));
    }
    e.preventDefault;
    return false;
  })

  $('#notificationsC .unread').livequery(function() {
    $(this).removeClass("unread", 15000);
  })

  /*
   * SEARCH
   */
  $(".search input, #block-user").autocomplete($('.search input').data('url'), {
    minChars: 3,
    width: 245,
    matchContains: true,
    autoFill: false,
    searchKey: 'name',
    formatItem: function(row, i, max) {
      return row.formattedItem;
    },
    formatMatch: function(row, i, max) {
      return row.name;
    },
    formatResult: function(row) {
      return row.name;
    }
  });
  $(".search input").result(function(event, data, formatted) {
    window.location = data.url;
  });

  /*
   * Block users
   */
  $("#block-user").result(function(event, data, formatted) {
    $.post(
            $('#static-data').data('d').blockUserCreate,
            {'userId':data.id},
            function(data) {
              window.location.reload();
            }
    )
  })

  /*
   * Social friends invite page
   */
  $('#social_friends .not-registered .friend:not(.invited)').click(function() {
    var $self = $(this);
    var $counter = $("#social_friends .invite_counter");
    if ($self.hasClass('on')) {
      $counter.find('span').text(parseInt($('#social_friends .invite_counter span').text()) - 1);
    }
    else {
      $counter.find('span').text(parseInt($('#social_friends .invite_counter span').text()) + 1);
    }

    $self.toggleClass('on');

    if (!$counter.is(':visible')) {
      $counter.show('scale', {}, 150);
    }
    else if (parseInt($counter.find('span').text()) == 0) {
      $counter.hide('scale', {}, 150);
    }

  })

  $('#create-custom-venue').live('click', function() {
    if ($(this).hasClass('on'))
    {
      $(this).text('Add My Own Venue');
      $('#invite_post_venue_id').removeAttr('disabled');
    }
    else
    {
      $('#invite_post_venue_id').val(0).attr('disabled', true)
      $(this).text('Cancel Add My Own Venue');
    }
    $(this).toggleClass('on');
    $('#custom-venue').toggle();
  })

  $('.toggle-nav .item').live('click', function() {
    $($(this).parent().data('group')).hide();
    $(this).addClass('on').siblings().removeClass('on')
    $($(this).data('target')).show()
  })

  markers = [];
  $('#post-map-coordinates').live('click', function() {
    height = $('#page').height()
    $('#post-map-canvas').height(height-95)
    var latlng = new google.maps.LatLng($('#post-map-coordinates').data('lat'), $('#post-map-coordinates').data('lon'));
    var myOptions = {
      zoom: 11,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var map = new google.maps.Map(document.getElementById("post-map-canvas"),
        myOptions);

    $('#post-map .venue').each(function(i, val) {
      setTimeout(function() {
        var latlng = new google.maps.LatLng($(val).data('lat'), $(val).data('lon'));
        var marker = new google.maps.Marker({
          position: latlng,
          map: map,
          animation: google.maps.Animation.DROP,
          title:$(val).data('name'),
          icon: "/assets/"+$(val).data('icon')
        });
        markers[$(val).data('sort')] = marker
        google.maps.event.addListener(marker, 'click', function(e) {
          $.ajax({
            type: 'get',
            url: $(val).data('url'),
            dataType: 'json',
            success: function(data) {
              var infowindow = new google.maps.InfoWindow({
                  content: data.content
              });
              infowindow.open(map,marker);
            }
          })
        });
      }, i * 200);
    })
  })

  $('#post-map .venue').live('click', function() {
    console.log($(this).data('sort'))
    google.maps.event.trigger(markers[$(this).data('sort')],"click")
  })
})