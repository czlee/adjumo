import Ember from 'ember';

export default Ember.Component.extend({

  actions: {

    showLockAndBans: function() {
      // Navbar UI Elements
      $(".lock-ban-nav").addClass("active")
      $(".allocation-nav.active").removeClass("active");
      // Table UI elements
      $(".preallocation").removeClass("hidden");
      $(".allocation").addClass("hidden");
    },

    showAllocation: function(allocationID) {
      // Navbar UI Elements
      $(".lock-ban-nav.active").removeClass("active")
      $(".allocation-nav.active").removeClass("active");
      var clickedAllocationClass = ".allocation-nav-" + allocationID;
      $(clickedAllocationClass).addClass("active");
      // Table UI elements
      $(".preallocation").addClass("hidden");
      $(".allocation").removeClass("hidden");
    },

    startNewAllocation: function() {
      // Navbar UI Elements
      $(".lock-ban-nav.active").removeClass("active")
      $(".allocation-nav.active").removeClass("active");
      // Table UI elements
      $(".preallocation").addClass("hidden");
      $(".allocation").removeClass("hidden");
      // Do this after the UI stuff as the new UI allocation has active on
      this.sendAction('startNewAllocation');
    }

  }

});
