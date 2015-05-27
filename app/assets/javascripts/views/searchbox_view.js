Sfmovies.Views.SearchboxView = Backbone.View.extend({
  el: 'input',
  initialize: function() {
    this.engine = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.whitespace,
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      remote: {
        url: '/api/v1/movies/autocomplete/%QUERY',
        wildcard: '%QUERY',
        cache: false,
        rateLimitWait: 50,
        transform: function(response) {
          var temp = [];
          response.forEach(function(res){
            temp.push(res.movie.title);
          });
          return temp;
        }
      },
      limit: 10,
    });
  },
  render: function() {
    this.engine.initialize();

    this.$el.typeahead(null, {
      limit: 10,
      cache: false,
      source: this.engine.ttAdapter()
    });
  },
  events: {
    "keypress": "keyPress"
  },
  keyPress: function(event) {
    if (event.which == 13) {
      this.doSearch(this.$el.val());
    }
  },
  doSearch: function(query) {
    movie = new Sfmovies.Models.Movie(query);
    movie.fetch({
      success: function(movie) {
        Sfmovies.mapView.locationsReseted(movie.get('locations'));
        movieInfo = new Sfmovies.Views.MovieInfoView(movie);
        movieInfo.render();
        $('#movie-info').html(movieInfo.el);
      }
    });
  }
});
