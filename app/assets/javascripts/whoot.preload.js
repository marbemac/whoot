/*
 * Control the main content resizing
 */

var resizeLayout = function() {
  var h = $(window).height() - $('#header').height();
  if ($('#sidebar').length > 0) {
    $('#sidebar').css('height', h);
  }
  if ($('#page_content').length > 0) {
    var $feedFiltersAdjust = 0;
    if ($('#feed-filters').length > 0) {
      $feedFiltersAdjust = 2+$('#feed-filters').height() +
              parseInt($('#feed-filters').css('margin-bottom').replace("px", "")) +
              parseInt($('#feed-filters').css('padding-bottom').replace("px", "")) * 2;
    }
    $('#page_content').css('height', h - $feedFiltersAdjust - parseInt($('#page_content').css('margin-bottom').replace('px', '')));
  }
}

// on first load
$('body').livequery(function() {
  resizeLayout();
})

// on window resize
$(window).resize(function() {
  resizeLayout();
});

if ($('body').width() > 1300) {
  $('.undecidedC').removeClass('collapsed');
}