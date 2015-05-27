Sfmovies.Models.Movie = Backbone.Model.extend({
  initialize: function(title) {
    this.movieTitle = title;
  },
  urlRoot: function() {
    return '/api/v1/movies/search/?title=' + this.movieTitle;
  },
  parse: function(response) {
    response = response.movie;
    locations = [];
    response.locations.forEach(function(loc) {
      locations.push(loc.location);
    });
    response.locations = new Sfmovies.Collections.Locations(locations);
    response.release_year = new Date(response.release_year);
    return response;
  }
});
