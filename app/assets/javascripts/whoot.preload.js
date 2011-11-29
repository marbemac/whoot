/*
 * Control the main content resizing
 */

var resizeLayout = function() {
  $('#wrapper').css('min-height', $(window).height() - $('#header').height());
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