import Ember from 'ember';

export default Ember.Component.extend({

  actions: {

    createAllocation: function() {
      console.log('new allocation');
      $(".preallocation, .allocation").toggleClass("hidden");
    }

  }

});
