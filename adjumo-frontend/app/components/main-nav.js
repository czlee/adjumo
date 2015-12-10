import Ember from 'ember';

export default Ember.Component.extend({

  showingGender: false,
  showingRegion: false,

  actions: {

    showGender: function() {
      this.set('showingGender', true);
      $(".adjudicator-ui, .debate-team").toggleClass("gender-display");
    },
    hideGender: function() {
      this.set('showingGender', false);
      $(".adjudicator-ui, .debate-team").toggleClass("gender-display");
    },
    showRegion: function() {
      this.set('showingRegion', true);
      $(".adjudicator-ui, .debate-team").toggleClass("region-display");
    },
    hideRegion: function() {
      this.set('showingRegion', false);
      $(".adjudicator-ui, .debate-team").toggleClass("region-display");
    },

  }

});
