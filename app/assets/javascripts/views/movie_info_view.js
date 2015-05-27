Sfmovies.Views.MovieInfoView = Backbone.View.extend({
  template: JST['movie_info'],
  initialize: function(movie_model) {
    this.movie_model = movie_model;
  },
  render: function() {
    var title = this.movie_model.get('title');
    this.$el.html(this.template({movie: this.movie_model}));
  },
});
