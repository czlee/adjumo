import Ember from 'ember';

export default Ember.Route.extend({

  model: function() {
      return Ember.RSVP.hash({ // Need this to return multiple model types
          debates:        this.store.findAll('debate'), // Makes a GET to /debates (currently handled as mock serve by mirate)
          adjudicators:   this.store.findAll('adjudicator'),
          regions:        this.store.findAll('region'),
          institutions:   this.store.findAll('institution')
      })
  },

  actions: {


  }



});
