Sfmovies.Views.MapView = Backbone.View.extend({
  el: '.map',
  initialize: function() {
    this.geocoder = new google.maps.Geocoder();
    this.markers = [];
    this.infoWindows = [];
  },
  render: function() {
    this.map = new google.maps.Map(this.$el[0], {
      zoom: 13,
      center: new google.maps.LatLng(37.7544066, -122.44768449999998),
    });
  },
  addMarker: function(location) {
    var map = this.map;
    var addressWithMoreInfo = location.get('name') + ', San Francisco, CA, US';
    var markers = this.markers;
    var infoWindows = this.infoWindows;
    this.geocoder.geocode({'address': addressWithMoreInfo}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        var address = results[0];
        map.setCenter(address.geometry.location);
        var infoWindow = new google.maps.InfoWindow({
          content: "<div class='info-window'><p><b>" + 
                    location.get('name') + "</b></p>" + 
                    address.formatted_address + "</div>"
        });
        var marker = new google.maps.Marker({
          map: map, 
          position: address.geometry.location,
          animation: google.maps.Animation.DROP,
        });
        google.maps.event.addListener(marker, 'click', function() {
          infoWindows.forEach(function(infoWindow) {
            infoWindow.close(map, marker);
          });
          infoWindow.open(map, marker);
        });
        markers.push(marker);
        infoWindows.push(infoWindow);
      } else {
        console.log('warning', status);
      }
    });
  },
  removeAllMarkers: function() {
    this.markers.forEach(function(marker) {
      marker.setMap(null);
    });
  },
  locationsReseted: function(locations) {
    this.removeAllMarkers();
    var that = this;
    for (var i = 0; i < locations.models.length; ++i) {
      this.addMarker(locations.models[i]);
    }
  }
});
