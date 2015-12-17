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
      this.currentAllocationIteration += 1;

      // Create a new allocation
      var newAllocation = this.store.createRecord('allocation-iteration', {
        id: this.currentAllocationIteration,
      });

      // this.store.findAll('panel').then().filterBy('allocation', null).set('allocation', newAllocation)
      this.store.findAll('panelallocation').then((panels) => {
        panels.forEach(function(item, index) {
          if (item.get('allocation')) {
            item.set('allocation', newAllocation);
          }
        });
      });

    }

  }



});
