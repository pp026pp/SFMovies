window.Sfmovies = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: function() {
    this.searchView = new Sfmovies.Views.SearchboxView();
    this.searchView.render();
    this.mapView = new Sfmovies.Views.MapView();
    this.mapView.render();
  }
};

$(document).ready(function(){
  Sfmovies.initialize();
});
