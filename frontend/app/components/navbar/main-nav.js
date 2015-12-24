import Ember from 'ember';

export default Ember.Component.extend({

  showingLockBans: true,

  actions: {

    toggleLockAndBans: function() {
      // Navbar UI Elements
      this.set('showingLockBans', !this.get('showingLockBans'));
      // Table UI elements
      $(".preallocation").toggleClass("hidden");
      $(".allocation").toggleClass("hidden");
      // Adj Area
      $(".all-adjs-panel").toggleClass("hidden");
      $(".unused-adjs-panel").toggleClass("hidden");
    },

    startNewAllocation: function() {
      // Navbar UI Elements
      this.set('showingLockBans', false);

      // Table UI elements
      $(".preallocation").addClass("hidden");
      $(".allocation").removeClass("hidden");
      // Do this after the UI stuff as the new UI allocation has active on

      // Adj Area
      $(".all-adjs-panel").addClass("hidden");
      $(".unused-adjs-panel").removeClass("hidden");

      this.sendAction('startNewAllocation'); // Calls up to index.js' createAllocation

    },

    startNewConfig: function() {
      $('#setAllocationParameters').modal('hide');
      this.sendAction('finishSaveConfig');
    }

  }

});
