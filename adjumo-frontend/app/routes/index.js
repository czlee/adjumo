import Ember from 'ember';

export default Ember.Route.extend({

  model: function() {
      return Ember.RSVP.hash({ // Need this to return multiple model types
          regions:        this.store.findAll('region'),
          institutions:   this.store.findAll('institution'),
          adjudicators:   this.store.findAll('adjudicator'),
          teams:          this.store.findAll('team'),
          debates:        this.store.findAll('debate'), // Makes a GET to /debates (currently handled as mock serve by mirate)
      })
  },

  actions: {


  }



});
