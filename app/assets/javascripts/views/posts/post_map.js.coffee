class Whoot.Views.PostMap extends Backbone.View
  id: 'post-map'

  initialize: ->

  render: =>
    $(@el).html('<div id="map-canvas"></div>')
    @

  buildMap: =>
    console.log Whoot.App.current_user
    markers = []
    currentInfoWindow = null
    height = $('#post-map').height()
    latlng = new google.maps.LatLng(Whoot.App.current_user.get('location').coordinates[1], Whoot.App.current_user.get('location').coordinates[0])
    myOptions = {
      zoom: 11,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    map = new google.maps.Map(document.getElementById("map-canvas"), myOptions)

    venues = []
    for post in @collection.collection.models
      if post.get('venue')
        found = _.any(venues, (venueData) -> venueData.venue._id == post.get('venue')._id)
        unless found
          found = {
            venue: post.get('venue')
            posts: []
          }
          venues.push found
        found['posts'].push(post)

    for venueData in venues
      latlng = new google.maps.LatLng(venueData.venue.coordinates[1], venueData.venue.coordinates[0])

      marker = new google.maps.Marker
        position: latlng
        map: map
        animation: google.maps.Animation.DROP
        title: 'test'
        icon: "/assets/map_pin_fill_18x29.png"

      markers[venueData.venue._id] = marker

      google.maps.event.addListener marker, 'click', (e) ->
        view = new Whoot.Views.PostMapInfoWindow(model: venueData)
        infowindow = new google.maps.InfoWindow
          content: $(view.render().el).get()[0].outerHTML

        if (currentInfoWindow != null)
          currentInfoWindow.close()

        infowindow.open(map, marker)
        currentInfoWindow = infowindow

#        google.maps.event.addListener marker, 'click', (e) ->
#          $.ajax
#            type: 'get'
#            url: $(val).data('url'),
#            dataType: 'json',
#            cache: false,
#            success: function(data) {
#              var infowindow = new google.maps.InfoWindow({
#                  content: data.content
#              });
#              if (currentInfoWindow != null) {
#                  currentInfoWindow.close();
#              }
#              infowindow.open(map, marker);
#              currentInfoWindow = infowindow;
#            }
#          })

    #        $('#post-map .venue').each(function(i, val) {
    #          setTimeout(function() {
    #            var latlng = new google.maps.LatLng($(val).data('lat'), $(val).data('lon'));
    #            var marker = new google.maps.Marker({
    #              position: latlng,
    #              map: map,
    #              animation: google.maps.Animation.DROP,
    #              title:$(val).data('name'),
    #              icon: "/assets/"+$(val).data('icon')
    #            });
    #            markers[$(val).data('id')] = marker
    #            google.maps.event.addListener(marker, 'click', function(e) {
    #              $.ajax({
    #                type: 'get',
    #                url: $(val).data('url'),
    #                dataType: 'json',
    #                cache: false,
    #                success: function(data) {
    #                  var infowindow = new google.maps.InfoWindow({
    #                      content: data.content
    #                  });
    #                  if (currentInfoWindow != null) {
    #                      currentInfoWindow.close();
    #                  }
    #                  infowindow.open(map, marker);
    #                  currentInfoWindow = infowindow;
    #                }
    #              })
    #            });
    #          }, i * 200);
    #        })