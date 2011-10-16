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
    if ($(ev.target).is('a') || $(ev.target).hasClass('tag') || postActivityToggle)
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

  // Search for a venue
  $(".venue_input .name").autocomplete($('#static-data').data('d').venueAutoUrl, {
    minChars: 2,
    width: 475,
    matchContains: true,
    matchSubset: false,
    autoFill: false,
    selectFirst: true,
    mustMatch: false,
    searchKey: 'term',
    max: 10,
    bucket: $('#static-data').data('d').venueAutoBucket,
    bucketType: 'venue',
    extraParams: {"types":[$('#static-data').data('d').venueAutoBucket]},
    dataType: 'json',
    delay: 100,
    formatItem: function(row, i, max) {
      return row.formattedItem;
    },
    formatMatch: function(row, i, max) {
      return row.term;
    },
    formatResult: function(row) {
      return row.term;
    }
  }).result(function(event, data, formatted) {
    var parent = $(this).parents('.venue_input');
    if (data.id == 0)
    {
//      parent.find('.address_fields').show().find('.address_placeholder').val('');
      parent.find('.venue_id').val('');
    }
    else
    {
//      parent.find('.address_fields').hide().find('.address_placeholder').val('');
      parent.find('.phone, .coordinates').val('');
      parent.find('.venue_id').val(data.id);
    }
  }).blur(function(e) {
    var parent = $(this).parents('.venue_input');
    if (parent.find('.venue_id').val() == '')
    {
//      parent.find('.address_fields').show();
    }
    if ($(this).val() == '') {
//      parent.find('.address_fields').hide();
    }
  })

  // Show the post-where places autocomplete
  $('.venue_input').livequery(function() {
    var $self = $(this);
    var $auto = new google.maps.places.Autocomplete(document.getElementById($self.find('.address_fields .address_placeholder').attr('id')));

    // Handle a place choice
    google.maps.event.addListener($auto, 'place_changed', function() {
      var place = $auto.getPlace();
      console.log(place);
      $self.find('.address_fields .address').val(place.formatted_address);
      $self.find('.coordinates').val(place.geometry.location.lng() + ' ' + place.geometry.location.lat());
      if (place.name && ($.inArray('restaurant', place.types) > 0 || $.inArray('food', place.types) > 0 || $.inArray('establishment', place.types) > 0))
      {
        $self.find('.name').val(place.name)
      }
      if (place.formatted_phone_number)
      {
        $self.find('.phone').val(place.formatted_phone_number)
      }
    })
  })
  $('.venue_input .address_placeholder').live('keypress', function(e) {
    if(window.event)
      key = window.event.keyCode;
    else
      key = e.which;
    if(key == 13)
    {
      e.preventDefault();
      return false;
    }
  })
  $('.venue_input .address_placeholder').live('keyup', function(e) {
    $(this).next().val($(this).val());
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

  // Filter posts by tag
  $('#post-feed .tag').live('click', function() {
    var $self = $(this);

    if ($('#post-feed-my-tags li[data-id="' + $(this).data('id') + '"]').length == 0) {
      $('#post-feed-my-tags').slideDown(150);

      $('#post-feed-my-tags .tags').append('<li data-id="'+$self.data('id')+'">'+$self.text()+'<span>x</span></li>');
      $('.post.teaser').each(function() {
        if ($(this).find('.tag[data-id="' + $self.data('id') + '"]').length == 0) {
          $(this).hide();
        }
      })
    }
  })

  // Remove a filtered tag
  $('#post-feed-my-tags li').live('click', function() {
    var $tag = $(this);

    var $filteredFound = false;
    var $filteredTags = '';
    $.each($('#post-feed-my-tags li'), function() {
      if ($(this).data('id') != $tag.data('id')) {
        $filteredFound = true;
        $filteredTags += '[data-id="' + $(this).data('id') + '"], ';
      }
    })

    if (!$filteredFound) {
      $('.post.teaser').fadeIn(150);
    }
    else {
      $('.post.teaser').each(function() {
        if ($(this).find($filteredTags).length != 0) {
          $(this).fadeIn(150);
        }
      })
    }
    $(this).remove();

    if ($('#post-feed-my-tags li').length == 0) {
      $('#post-feed-my-tags').slideUp(150);
    }
  })

  /*
   * LISTS
   */
  $('.list-createB').livequery(function() {
    $(this).colorbox({transition: "none", opacity: .5, inline: true, href: "#new_list"});
  })

  $("#list-add-user").autocomplete($('#static-data').data('d').userAutoUrl, {
    minChars: 2,
    width: 300,
    matchContains: true,
    matchSubset: false,
    autoFill: false,
    selectFirst: true,
    mustMatch: true,
    searchKey: 'term',
    max: 10,
    bucket: $('#static-data').data('d').userAutoBucket,
    bucketType: 'user',
    extraParams: {"types":[$('#static-data').data('d').userAutoBucket]},
    dataType: 'json',
    delay: 100,
    formatItem: function(row, i, max) {
      return row.formattedItem;
    },
    formatMatch: function(row, i, max) {
      return row.term;
    },
    formatResult: function(row) {
      return row.term;
    }
  }).result(function(event, data, formatted) {
    if (data)
    {
      $.post($('#list-add-user').data('url-add'), {'user_id': data.id}, function(data) {
        appUpdate(data);
      }, 'json');
    }
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
   * SEARCH
   */
  $(".search input, #block-user").autocomplete($('#static-data').data('d').userAutoUrl, {
    minChars: 2,
    width: 245,
    matchContains: true,
    matchSubset: false,
    autoFill: false,
    selectFirst: true,
    mustMatch: true,
    searchKey: 'term',
    max: 10,
    bucket: $('#static-data').data('d').userAutoBucket,
    bucketType: 'user',
    extraParams: {"types":[$('#static-data').data('d').userAutoBucket, 'user']},
    dataType: 'json',
    delay: 100,
    formatItem: function(row, i, max) {
      return row.formattedItem;
    },
    formatMatch: function(row, i, max) {
      return row.term;
    },
    formatResult: function(row) {
      return row.term;
    }
  }).result(function(event, data, formatted) {
    if (data)
    {
      window.location = data.data.url
    }
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

  $('.toggle').live('click', function() {
    $($(this).data('target')).toggle();
  })
})