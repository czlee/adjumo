import Ember from 'ember';

export default Ember.Route.extend({

  model: function() {
      return Ember.RSVP.hash({ // Need this to return multiple model types

          config:                 this.store.createRecord('allocation-config'),
          regions:                this.store.findAll('region'),
          institutions:           this.store.findAll('institution'),
          adjudicators:           this.store.findAll('adjudicator'),
          teams:                  this.store.findAll('team'),
          debates:                this.store.findAll('debate'),
          allocations:             this.store.findAll('allocation-iteration', 'id', { reload: true }),

      })
  },

  allocationIteration: 0,

  actions: {

    createAllocation: function() {
      this.allocationIteration += 1;
      this.store.createRecord('allocation-iteration', { id: this.allocationIteration });
    }

  }



});
