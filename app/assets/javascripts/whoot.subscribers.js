// Wait for Document
$(function() {

  var actionCommon = function(target, data) {
    if (data.newText) {
      target.text(data.newText);
    }

    if (data.newUrl) {
      target.attr('href', data.newUrl);
    }
  }

  var deleteCommon = function (data) {
    $('.o_' + data.objectId).remove();
  }

  /*
   * USERS
   */

  amplify.subscribe("follow_toggle", function(data) {
    actionCommon($('.fol_' + data.userId), data);

    if (data.status == 'new') {
      $('#my-following').text(parseInt($('#my-following').text()) + 1);
    }
    else {
      $('#my-following').text(parseInt($('#my-following').text()) - 1);
    }
  });

  amplify.subscribe("ping_toggle", function(data) {
    if (data.status == 'new') {
      actionCommon($('.ping-' + data.userId), data);

      $('.ping-' + data.userId).replaceWith('<span class="pinged">Pinged</span>');
    }
  });

  amplify.subscribe("used_ping", function(data) {
    $('#pings-remaining .used').text(parseInt($('#pings-remaining .used').text()) + 1);
  });

  amplify.subscribe("location_updated", function(data) {
    $('#collect-info-box').fadeOut(200, function() {
      $(this).remove();
    })
  });

  amplify.subscribe("user_invited", function (data) {
    $('.new_user_invite .email').val($('.new_user_invite .email').data('default')).effect('highlight', {}, 2000).click();
  });

  amplify.subscribe("user_unblocked", function (data) {
    $currentTarget.parent().remove();
  });

  amplify.subscribe("settings_updated", function (data) {
    var statuses = {'off':'on','on':'off'}
    $currentTarget.prev().find('span').text(statuses[$currentTarget.prev().find('span').text()]);
  });

  amplify.subscribe("user_invted", function (data) {
    $('#invite_email').val('')
  })

  /*
   * POSTS
   */

  amplify.subscribe("post_created", function(data) {
    $('#post-box').fadeOut(300);

    $('#my-post').replaceWith(data.myPost);
  });

  amplify.subscribe('post_map_loaded', function(data) {
    $('#post-map').html(data.content);
    $('#post-map-coordinates').click();
  })

  amplify.subscribe('venue_attending_loaded', function(data) {
    $('#post-my-venue').html(data.content);
  })

  amplify.subscribe('updated_feed_filters', function(data) {
    $currentTarget.parent().toggleClass('on');
  })

  /*
   * VOTING
   */
  // Listens to votes being registered.
  amplify.subscribe("voted", function(data) {
    var target = $('#post-'+data.user_id);
    target.find('.votes').text(data.votes).effect("highlight", {color: '#FC770D'}, 2000);;
    target.find('.voters .none').remove();
    target.find('.voters').append(data.voter);
  });

  /*
   * COMMENTS
   */
  amplify.subscribe("comment_created", function(data) {
    $('.comment_new .content').val($('.comment_new .content').data('default'));
    $('.cf-' + data.root_id).find('textarea').val('').blur();
    $('.cf-' + data.root_id).find('#new_comment').after(data.comment);
    var comment_count = $('#post-' + data.user_id + ' .comments_count span');
    comment_count.text(parseInt(comment_count.text()) + 1);
  });
  amplify.subscribe("comment_destroyed", function(data) {
    $('#c-' + data.event_id).remove();
    console.log(data.event_id);
    var comment_count = $('#post-' + data.user_id + ' .comments_count span');
    comment_count.text(parseInt(comment_count.text()) - 1);
  });

  /*
   * NOTIFICATIONS
   */
  amplify.subscribe('my_notifications', function (data) {
    $('#unread-notification-count').removeClass('ac').prepend(data.content).find('span').removeClass('on').text('0');
    $('#unread-notification-count').live('click', function(e) {
      if (e.target.tagName != 'a')
      {
        $('#notificationsC').toggle();
      }
    })
  })

  /*
   * LISTS
   */

  // Listens for when the add list button is clicked
  amplify.subscribe("list_form", function(data) {
    $.colorbox({title:"Create a List!", transition: "none", scrolling: false, opacity: .5, html: data.form });
  });

  // Listens for when a list is created
  amplify.subscribe("list_created", function(data) {
    $.colorbox.remove();
    $('.my-lists .lists').append('<li>' + data.object + '</li>').find('.none').remove();
  });

  // Listens for when a list is deleted
  amplify.subscribe("list_deleted", function(data) {
    $('.l_' + data.objectId).remove();
  });

  // Listens for when a list user is deleted
  amplify.subscribe("list_user_deleted", function(data) {
    $('#uld-' + data.objectId).parent().remove();
  });

  // Listens for when a list user is added
  amplify.subscribe("list_user_added", function(data) {
    $('#list-user-panel ul').prepend(data.user);
  });


});