jQuery ->

  # Toggle the activity of a post
  $('.teaser.post .head').live 'click', (ev) ->
    console.log('test')
    if ($(ev.target).is('a') || $(ev.target).hasClass('tag'))
      return

    $(@).toggleClass('on');
    $(@).siblings('.details').slideToggle(150);

  # Tag autocomplete
  $("#post_tag_name").autocomplete $('#static-data').data('d').tagAutoUrl,
    minChars: 2,
    width: 475,
    matchContains: true,
    matchSubset: false,
    autoFill: false,
    selectFirst: true,
    mustMatch: false,
    searchKey: 'term',
    max: 10,
    buckets: [['tag', 'tag', 'TAGS']],
    extraParams: {"types":['tag']},
    allowNew: true,
    allowNewName: 'tag',
    allowNewType: 'tag',
    dataType: 'json',
    delay: 100,
    formatItem: (row, i, max) ->
      return row.formattedItem
    formatMatch: (row, i, max) ->
      return row.term
    formatResult: (row) ->
      return row.term
  .result (event, data, formatted) ->
    $(@).val(data.term)