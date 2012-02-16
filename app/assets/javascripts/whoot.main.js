$(function() {

  /**
   * SPLASH PAGE
   */

  // show the hidden login form on ctrl+L
  $(document).keypress(function(e) {
    var $code = e.which ? e.which : e.keyCode;
    if (e.ctrlKey && ($code == 108 || $code == 12)) {
      $('#auth-login,#fb_login,#coming-soon,#whoot-video').fadeToggle(300);
      return false;
    }
    else if (e.ctrlKey && ($code == 99 || $code == 3)) {
      $('#auth-register').fadeToggle(300);
      return false;
    }
    else if (e.ctrlKey && ($code == 101 || $code == 5)) {
      window.location = document.URL + '?_switch_user=_exit';
    }
  });

  $("#site-launch-cd").countdown({
    "date": "february 16, 2012 00:00:00",
    "fx": "fade"
  });


  $('#why_facebook').qtip({
    content: {
      text: 'Partnering with Facebook provides Whoot users with secure account access ' +
              'and makes it easier than ever to connect with your pre-existing Facebook network on The Whoot.'
    },
    style: {classes: 'ui-tooltip-shadow ui-tooltip-light', tip: true},
    position: {
      my: 'top center',
      at: 'bottom center',
      viewport: $(window)
    },
    show: {delay: 200},
    hide: {delay: 200, fixed: false}
  })

  $('#splash .static_pages div').each(function(i,val) {
    var self = $(this);
    self.colorbox({
      href:self.data('url'),
      maxWidth: '80%',
      maxHeight: '80%'
    });
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

  changeLocation = function(url, id)
  {
    $.ajax({
      type: 'put',
      url: url,
      dataType: 'json',
      data:{id:id},
      success: function(data) {
        appUpdate(data);
      }
    })
  }

  $('#feed-nav .location').live('click', function() {
    var $self = $(this);
    changeLocation($self.parents('.locations:first').data('url'), $self.data('id'));
  })

  $('#my-location').live('change', function() {
    var $self = $(this);
    changeLocation($self.data('url'), $self.val());
  })

  // Tweet post
  $('#my-post .tweet:not(.off)').live('click', function() {
    var $self = $(this);
    $.colorbox({
      title:false,
      transition: "elastic",
      speed: 100,
      opacity: '.95',
      fixed: true,
      html: $self.next().html()
    });
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
  $('#post-box .type').live('click', function() {
    $(this).addClass('on').siblings('.type').removeClass('on');
    $(this).parent().find('.post_type').val($(this).data('val'));
  })

  // Cancel a change post
  $('#post-box .cancel').live('click', function() {
    $('#post-box').fadeOut(300);
  })

  // Venue private help ?
  $('.venue-private-help').livequery(function() {
    var $self = $(this);
    $self.qtip({
      content: {
        text: 'If the venue you are adding is your house/apartment/dorm room mark it as private to keep it from showing up when other users search for venues.'
      },
      style: {classes: 'ui-tooltip-shadow ui-tooltip-light', tip: true},
      position: {
        my: 'middle left',
        at: 'middle right',
        viewport: $(window)
      },
      show: {delay: 100},
      hide: {delay: 200, fixed: false}
    })
  })

  // Show the post-where places autocomplete
  $('.venue_input').livequery(function() {
    var $self = $(this);
    var $auto = new google.maps.places.Autocomplete(document.getElementById($self.find('.address_fields .address_placeholder').attr('id')));

    // Handle a place choice
    google.maps.event.addListener($auto, 'place_changed', function() {
      var place = $auto.getPlace();

      $self.find('.address_fields .address').val(place.formatted_address);
      $self.find('.coordinates').val(place.geometry.location.lng() + ' ' + place.geometry.location.lat());
      if (place.name && ($.inArray('restaurant', place.types) > 0 || $.inArray('food', place.types) > 0 || $.inArray('establishment', place.types) > 0))
      {
        $self.find('.name').focus().val(place.name).blur()
      }
      if (place.formatted_phone_number)
      {
        $self.find('.phone').val(place.formatted_phone_number)
      }
    })
  })

  $('.address_placeholder').live('keypress', function(e) {
    if (e.keyCode == 13)
    {
      return false;
    }
  })

  // Toggle the trending bar
  $('#trending-barC').live('click', function() {
    $(this).toggleClass('on');
    $('#trending-bar').slideToggle(150);
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
  $('#post-feed .tag, #trending-bar .tag').live('click', function() {
    var $self = $(this);

    $('#post-feed-my-venues').slideUp(150);
    $('#post-feed-my-venues .venues').html('')

    if ($('#post-feed-my-tags li[data-id="' + $(this).data('id') + '"]').length == 0) {
      $('#post-feed-my-tags').slideDown(150);
      $('#post-feed-my-tags .tags').html('')
      $('.post.teaser:not(#post-dummy)').show()
      $('#post-feed-my-tags .tags').append('<li data-id="'+$self.data('id')+'">'+$self.text()+'<span>x</span></li>');
      $('.post.teaser:not(#post-dummy)').each(function() {
        if ($(this).find('.tag[data-id="' + $self.data('id') + '"]').length == 0) {
          $(this).hide();
          if ($(this).next().hasClass('post-details') && $(this).hasClass('on'))
            $(this).next().hide()
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
      $('.post.teaser:not(#post-dummy)').fadeIn(150);
      $('.post-details').each(function(i,val) {
        if ($(val).prev().hasClass('on'))
          $(val).show();
      })
    }
    else {
      $('.post.teaser:not(#post-dummy)').each(function() {
        if ($(this).find($filteredTags).length != 0) {
          $(this).fadeIn(150);
          if ($(this).next().hasClass('post-details') && $(this).hasClass('on'))
            $(this).next().fadeIn(150)
        }
      })
    }
    $(this).remove();

    if ($('#post-feed-my-tags li').length == 0) {
      $('#post-feed-my-tags').slideUp(150);
    }
  })

  /*
   * venues
   */

  // Filter posts by venue
  $('#trending-bar .venue').live('click', function() {
    var $self = $(this);

    $('#post-feed-my-tags').slideUp(150);
    $('#post-feed-my-tags .tags').html('')

    if ($('#post-feed-my-venues li[data-id="' + $(this).data('id') + '"]').length == 0) {
      $('#post-feed-my-venues').slideDown(150);
      $('#post-feed-my-venues .venues').html('')
      $('.post.teaser:not(#post-dummy)').show()
      $('#post-feed-my-venues .venues').append('<li data-id="'+$self.data('id')+'">'+$self.text()+'<span>x</span></li>');
      $('.post.teaser, .post-details').hide()
      $('.post.teaser[data-venue-id="'+$self.data('id')+'"]:not(#post-dummy)').each(function() {
        $(this).show();
        if ($(this).next().hasClass('post-details') && $(this).hasClass('on'))
          $(this).next().show()
      })
    }
  })

  // Remove a filtered tag
  $('#post-feed-my-venues li').live('click', function() {
    var $venue = $(this);

    var $filteredFound = false;
    var $filteredVenue = '';
    $.each($('#post-feed-my-venues li'), function() {
      if ($(this).data('id') != $venue.data('id')) {
        $filteredFound = true;
        $filteredVenue += '[data-venue-id="' + $(this).data('id') + '"]';
      }
    })

    if (!$filteredFound) {
      $('.post.teaser:not(#post-dummy)').fadeIn(150);
      $('.post-details').each(function(i,val) {
        if ($(val).prev().hasClass('on'))
          $(val).show();
      })
    }
    else {
      $('.post.teaser'+$filteredVenue+':not(#post-dummy)').each(function() {
        $(this).fadeIn(150);
        if ($(this).next().hasClass('post-details'))
          $(this).next().fadeIn(150)
      })
    }
    $(this).remove();

    if ($('#post-feed-my-venues li').length == 0) {
      $('#post-feed-my-venues').slideUp(150);
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
    matchSubset: false,
    autoFill: false,
    selectFirst: true,
    searchKey: 'term',
    max: 10,
    buckets: [['user', $('#static-data').data('d').userAutoBucket, 'FOLLOWING']],
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

  /*
   * SEARCH
   */
  $("#header .search input, #block-user").autocomplete($('#static-data').data('d').userAutoUrl, {
    minChars: 2,
    width: 245,
    matchSubset: false,
    autoFill: false,
    selectFirst: true,
    searchKey: 'term',
    max: 10,
    buckets: [['user', $('#static-data').data('d').userAutoBucket, 'FOLLOWING'], ['user', 'user', 'OTHER USERS']],
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

  $('.toggle-nav .item:not(.no-tog)').live('click', function() {
    $($(this).parent().data('group')).hide();
    $(this).addClass('on').siblings(':not(.no-tog)').removeClass('on')
    $($(this).data('target')).show()
  })

  markers = [];
  currentInfoWindow = null;
  $('#post-map-coordinates').live('click', function() {
    height = $('#wrapper').height() - $('#footer').height() - 10
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
        markers[$(val).data('id')] = marker
        google.maps.event.addListener(marker, 'click', function(e) {
          $.ajax({
            type: 'get',
            url: $(val).data('url'),
            dataType: 'json',
            cache: false,
            success: function(data) {
              var infowindow = new google.maps.InfoWindow({
                  content: data.content
              });
              if (currentInfoWindow != null) {
                  currentInfoWindow.close();
              }
              infowindow.open(map, marker);
              currentInfoWindow = infowindow;
            }
          })
        });
      }, i * 200);
    })
  })

  $('#post-map .venue').live('click', function() {
    google.maps.event.trigger(markers[$(this).data('id')],"click")
  })

  $('.toggle').live('click', function() {
    $($(this).data('target')).toggle();
  })
})