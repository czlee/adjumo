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
          allocations:            this.store.findAll('allocation-iteration', 'id', { reload: true }),

      })
  },

  currentAllocationIteration: 0,

  actions: {

    createAllocation: function() {
      console.log(this.store.findAll('panel'));

      this.currentAllocationIteration += 1;
      // Create a new allocation and set it's panels to match the last output JSON

      console.log("test");

      var newAllocation = this.store.createRecord('allocation-iteration', {
        id: this.currentAllocationIteration,
      });

      //this.store.findAll('panel').filterBy('allocation-iteration', null).set('allocation-iteration', newAllocation);

      console.log(this.store.findAll('panel').get('length'));

    }

  }



});
