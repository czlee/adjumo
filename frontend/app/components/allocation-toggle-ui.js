import Ember from 'ember';

export default Ember.Component.extend({

  tagName: 'span',

  actions: {

    toggleAllocation: function(allocationID) {
      // Navbar UI Elements
      this.get('allocation').set('active', !this.get('allocation').get('active'));
    },

  }

});
