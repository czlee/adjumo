import Ember from 'ember';

export default Ember.Route.extend({

  model: function() {
      return Ember.RSVP.hash({ // Need this to return multiple model types
          adjudicators:   this.store.findAll('adjudicator'),
          debates:        this.store.findAll('debate') // Makes a GET to /debates (currently handled as mock serve by mirate)
      })
  },

  actions: {

    // setAdjLocked: function(adjudicator) {

    //   App.Adapter.ajax('/songs/' + song.get('id'), {
    //     type: 'PUT',
    //     data: { rating: song.get('rating') }
    //   }).then(function() {
    //     console.log("Rating updated");
    //   }, function() {
    //     alert('Failed to set new rating');
    //   });
    // },
    // setAdjUnlocked: function(adjudicator) {

    //   App.Adapter.ajax('/songs/' + song.get('id'), {
    //     type: 'PUT',
    //     data: { rating: song.get('rating') }
    //   }).then(function() {
    //     console.log("Rating updated");
    //   }, function() {
    //     alert('Failed to set new rating');
    //   });

    // }

  }



});
