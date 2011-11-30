jQuery ->

  if $('#static-data').data('d').myId != 0
    channel = pusher.subscribe($('#static-data').data('d').myId+"_private");
    channel.bind 'notification', (data) ->
      createGrowl(false, data.content, '', 'green')

  if ($('#subscribe-users').length > 0)
    $($('#subscribe-users').data('ids')).each (index, val) ->
      channel = pusher.subscribe(val);
      channel.bind 'comment_added', (data) ->
        if (data.user_id == $('#static-data').data('d').myId)
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
        if (data.user_id == $('#static-data').data('d').myId)
          return;
        target = $('#post-'+data.user_id)
        target.find('.votes').text(data.votes).effect("highlight", {color: '#FC770D'}, 2000);
        target.find('.voters .none').remove()
        target.find('.voters').append(data.voter)

#  rebuildPost = (target, data) ->
#    target.removeClass('working low_in low_out big_out')
#    target.addClass(data.night_type)
#    target.find('.what').text(data.what)
#    target.find('.comments_count span').text('0')
#    target.find('.votes').text('0')
#    target.data('venue-id', data.venue_id)
#    tags = target.find('.tags')
#    tags.html('')
#    if (data.tag)
#      tags.append('<div class="tag" data-id="'+data.tag.id+'">'+data.tag.name+'</div>')

#  if ($('#subscribe-users').length > 0)
#    $($('#subscribe-users').data('ids')).each (index, val) ->
#      PUBNUB.subscribe({
#        channel: val,
#        callback: (data) ->
#          switch data.event
#            when 'post_changed'
#              target = $('#post-'+data.user_id)
#              if (target.length > 0)
#                rebuildPost(target, data)
#                if (target.next().hasClass('post-details'))
#                  target.removeClass('on').next().remove()
#              else
#                target = $('#post-dummy').clone()
#                rebuildPost(target, data)
#                target.attr('id', 'post-'+data.user_id)
#                target.data('details', '/posts/'+data.id)
#                target.find('.profile-image')
#                      .attr('title', data.fullname)
#                      .attr('href', '/users/'+data.encoded_id+'-'+data.user_slug)
#                      .html('
#                        <img style="max-width: 50px;" src="/users/'+data.encoded_id+'-'+data.user_slug+'/picture?d%5B%5D=50&d%5B%5D=50&s=square" />
#                      ')
#                target.find('.ulink-wrap').html('
#                  <a class="ulink" href="/users/'+data.encoded_id+'-'+data.user_slug+'">'+data.fullname+'</a>
#                ')
#                target.find('.votes').addClass('v-'+data.id)
#                target.find('.voteB').addClass('vb-'+data.id).find('.default').data('d', '{"id":"'+data.id+'"}')
#                $('#post-feed').prepend(target)
#
#              target.effect("highlight", {color: '#FC770D'}, 2000)
#
#            when 'voted'
#              target = $('#post-'+data.user_id)
#              if (target.length > 0)
#                target.find('.votes').text(data.votes).effect("highlight", {color: '#FC770D'}, 2000);
#                details = target.next()
#                if (details.hasClass('post-details'))
#                  if (target.hasClass('on'))
#                    $.ajax({
#                      url: $('#static-data').data('d').votesAjaxPath,
#                      data: {post_id: data.post_id},
#                      dataType: 'json',
#                      type: 'GET',
#                      cache: false,
#                      success: (voterData) ->
#                        voters = details.find('.voters')
#                        voters.find('div,a').remove()
#                        voters.append(voterData.content)
#                    })
#                  else
#                    details.remove()
#
#            when 'comment_added'
#              target = $('#post-'+data.user_id)
#              if (target.length > 0)
#                target.find('.comments_count span').text(data.count).effect("highlight", {color: '#FC770D'}, 2000);
#                details = target.next()
#                if (details.hasClass('post-details'))
#                  if (target.hasClass('on'))
#                    $.ajax({
#                      url: $('#static-data').data('d').commentAjaxPath,
#                      data: {post_id: data.post_id},
#                      dataType: 'json',
#                      type: 'GET',
#                      cache: false,
#                      success: (commentData) ->
#                        feed = details.find('.comment-feed')
#                        feed.find('.teaser').remove()
#                        feed.append(commentData.content)
#                    })
#                  else
#                    details.remove()
#              else
#                comment_feed = $('.cf-'+data.user_id)
#                console.log(comment_feed)
#                console.log(data.user_id)
#                if (comment_feed.length > 0)
#                  $.ajax({
#                    url: $('#static-data').data('d').commentAjaxPath,
#                    data: {post_id: data.post_id},
#                    dataType: 'json',
#                    type: 'GET',
#                    cache: false,
#                    success: (commentData) ->
#                      console.log(comment_feed)
#                      comment_feed.find('.teaser').remove()
#                      comment_feed.append(commentData.content)
#                  })
#      })
#
#  if ($('#static-data').data('d').myId != 0)
#    PUBNUB.subscribe({
#        channel: $('#static-data').data('d').myId+'_private',
#        callback: (data) ->
#          switch data.event
#            when 'notification'
#              createGrowl(false, data.content, '', 'green')
#    })