import Ember from 'ember';

export default Ember.Component.extend({

  showingLockBans: true,

  actions: {

    showLockAndBans: function() {
      // Navbar UI Elements
      this.set('showingLockBans', true);
      $(".allocation-nav.active").removeClass("active");
      $(".allocation-nav .glyphicon-eye-close").addClass("hidden");
      $(".allocation-nav .glyphicon-eye-open").removeClass("hidden");
      // Table UI elements
      $(".preallocation").removeClass("hidden");
      $(".allocation").addClass("hidden");
      // Adj Area
      $("#allAdjs").removeClass("hidden");
      $("#unusedAdjs").addClass("hidden");
    },

    showAllocation: function(allocationID) {
      // Navbar UI Elements
      this.set('showingLockBans', false);
      $(".allocation-nav.active").removeClass("active");
      $(".allocation-nav .glyphicon-eye-close").addClass("hidden");
      $(".allocation-nav .glyphicon-eye-open").removeClass("hidden");

      var clickedAllocationClass = ".allocation-nav-" + allocationID;
      $(clickedAllocationClass).addClass("active");
      $(clickedAllocationClass).children(".glyphicon-eye-open").addClass("hidden");
      $(clickedAllocationClass).children(".glyphicon-eye-close").removeClass("hidden");
      // Table UI elements
      $(".preallocation").addClass("hidden");
      $(".allocation").removeClass("hidden");
      // Adj Area
      $("#allAdjs").addClass("hidden");
      $("#unusedAdjs").removeClass("hidden");
    },

    startNewAllocation: function() {
      // Navbar UI Elements
      this.set('showingLockBans', false);
      $(".allocation-nav.active").removeClass("active");
      $(".allocation-nav .glyphicon-eye-close").addClass("hidden");
      $(".allocation-nav .glyphicon-eye-open").removeClass("hidden");

      // Table UI elements
      $(".preallocation").addClass("hidden");
      $(".allocation").removeClass("hidden");
      // Do this after the UI stuff as the new UI allocation has active on
      // Adj Area
      $("#allAdjs").addClass("hidden");
      $("#unusedAdjs").removeClass("hidden");

      this.sendAction('startNewAllocation'); // Calls up to index.js' createAllocation

      // Test POST
    },

    startNewConfig: function() {
      $('#setAllocationParameters').modal('hide');
      this.sendAction('finishSaveConfig');
    }

  }

});
