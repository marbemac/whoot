jQuery ->

  if $('#static-data').data('d').myId != 0
    channel = pusher.subscribe($('#static-data').data('d').myId+"_private");
    channel.bind 'notification', (data) ->
      createGrowl(false, data.content, '', 'green')

  if ($('#subscribe-users').length > 0)
    $($('#subscribe-users').data('ids')).each (index, val) ->
      channel = pusher.subscribe(val);
      channel.bind 'comment_added', (data) ->
        if (data.created_by == $('#static-data').data('d').myId)
          return;

        target = $('#post-'+data.user_id)
        target.find('.comments_count span').text(data.comment_count).effect("highlight", {color: '#FC770D'}, 2000);
        $.ajax({
          url: $('#static-data').data('d').commentAjaxPath,
          data: {post_id: data.post_id, comment_id: data.comment_id},
          dataType: 'json',
          type: 'GET',
          cache: false,
          success: (commentData) ->
            target.find('.comment-feed').append(commentData.comment)
        })

      channel.bind 'voted', (data) ->
        if (data.created_by == $('#static-data').data('d').myId)
          return;

        target = $('#post-'+data.user_id)
        target.find('.votes').text(data.votes).effect("highlight", {color: '#FC770D'}, 2000);
        target.find('.voters .none').remove()
        target.find('.voters').append(data.voter)

      channel.bind 'post_changed', (data) ->
        if (data.user_id == $('#static-data').data('d').myId)
          return;

        $.ajax({
          url: $('#static-data').data('d').postAjaxPath,
          data: {post_id: data.post_id},
          dataType: 'json',
          type: 'GET',
          cache: false,
          success: (postData) ->
            target = $('#post-'+data.user_id)
            if (target)
              target.replaceWith(postData.post)
            else
              $('#post-feed').prepend(postData.post)

            $('#post-'+data.user_id).effect("highlight", {color: '#FC770D'}, 2000)
        })