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
      },
      limit: 10,
    });
    this.alertElement = $('.input-alert');
    this.alertElement.hide();
  },
  render: function() {
    this.engine.initialize();

    this.$el.typeahead(null, {
      display: function(res) {
        return res.movie.title;
      },
      source: this.engine.ttAdapter()
    });
  },
  events: {
    "keypress": "keyPress"
  },
  keyPress: function(event) {
    if (event.which == 13) {
      this.$el.typeahead('close');
      this.doSearch(this.$el.val());
    }
  },
  doSearch: function(query) {
    movie = new Sfmovies.Models.Movie(query);
    var that = this;
    movie.fetch({
      success: function(movie) {
        Sfmovies.mapView.locationsReseted(movie.get('locations'));
        movieInfo = new Sfmovies.Views.MovieInfoView(movie);
        movieInfo.render();
        $('#movie-info').html(movieInfo.el);
      },
      error: function(movie, res) {
        that.$el.addClass('search-error');
        that.alertElement.html('Movie not found').show();
        setTimeout(function() {
          that.$el.removeClass('search-error');
          that.alertElement.html('').hide();
        }, 1000);
      },
    });
  }
});
