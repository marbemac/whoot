$(function() {

  $('#invite_friends').live('click', function() {
    FB.ui({method: 'apprequests', title: 'Invite Your Facebook Friends To The Whoot', message: 'Come follow me on The Whoot, the best way to organize your night!', data: $(this).data('uid'), filters: ['app_non_users']});
  })

})