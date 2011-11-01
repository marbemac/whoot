jQuery ->

  rebuildPost = (target, data) ->
    target.removeClass('working low_in low_out big_out')
    target.addClass(data.night_type)
    target.find('.what').text(data.what)
    target.find('.votes').text('0')
    tags = target.find('.tags')
    tags.html('')
    $(data.tags).each (i, val) ->
      tags.append('<div class="tag" data-id="'+val.id+'">'+val.name+'</div>')

  if ($('#subscribe-users').length > 0)
    $($('#subscribe-users').data('ids')).each (index, val) ->
      channel = pusher.subscribe(val);
      channel.bind 'post_changed', (data) ->
        target = $('#post-'+data.user_id)
        if (target.length > 0)
          rebuildPost(target, data)
        else
          target = $('#post-dummy').clone()
          rebuildPost(target, data)
          target.attr('id', 'post-'+data.user_id)
          target.data('details', '/normal_posts/'+data.id)
          target.find('.profile-image')
                .attr('title', data.fullname)
                .attr('href', '/users/'+data.encoded_id+'-'+data.user_slug)
                .html('
                  <img style="max-width: 50px;" src="/users/'+data.encoded_id+'-'+data.user_slug+'/picture?d%5B%5D=50&d%5B%5D=50&s=square" />
                ')
          target.find('.ulink-wrap').html('
            <a class="ulink" href="/users/'+data.encoded_id+'-'+data.user_slug+'">'+data.fullname+'</a>
          ')
          target.find('.votes').addClass('v-'+data.id)
          target.find('.voteB').addClass('vb-'+data.id).find('.default').data('d', '{"id":"'+data.id+'"}')
          $('#post-feed').prepend(target)

        target.effect("highlight", {color: '#FC770D'}, 2000)

      channel.bind 'voted', (data) ->
        target = $('#post-'+data.user_id)
        if (target.length > 0)
          target.find('.votes').text(data.votes).effect("highlight", {color: '#FC770D'}, 2000);

      channel.bind 'comment_added', (data) ->
        target = $('#post-'+data.user_id)
        target.find('.comments_count span').text(data.count).effect("highlight", {color: '#FC770D'}, 2000);


  if ($('#static-data').data('d').myId != 0)
    pusher.subscribe($('#static-data').data('d').myId+'_private').bind 'notification', (data) ->
      createGrowl(false, data.content, '', 'green');