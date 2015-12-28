import Ember from 'ember';

export default Ember.Component.extend({

  showingLockBans: true,

  showingGender: false,
  showingRegion: false,
  showingLanguage: false,
  showingRanking: false,

  genderOn: function() {
    this.set('showingGender', true);
    $("#wrap").addClass("gender-display");
    $(".debate-gender-deficits").show();
  },
  genderOff: function() {
    this.set('showingGender', false);
    $("#wrap").removeClass("gender-display");
    $(".debate-gender-deficits").hide();
  },
  regionOn: function() {
    this.set('showingRegion', true);
    $("#wrap").addClass("region-display");
    $(".debate-regional-deficits").show();
  },
  regionOff: function() {
    this.set('showingRegion', false);
    $("#wrap").removeClass("region-display");
    $(".debate-regional-deficits").hide();
  },
  languageOn: function() {
    this.set('showingLanguage', true);
    $("#wrap").addClass("language-display");
    $(".debate-language-deficits").show();
  },
  languageOff: function() {
    this.set('showingLanguage', false);
    $("#wrap").removeClass("language-display");
    $(".debate-language-deficits").hide();
  },
  rankingOn: function() {
    this.set('showingRanking', true);
    $("#wrap").addClass("ranking-display");
    $(".debate-quality-deficits").show();
  },
  rankingOff: function() {
    this.set('showingRanking', false);
    $("#wrap").removeClass("ranking-display");
    $(".debate-quality-deficits").hide();
  },

  roundInfo: Ember.inject.service('round-info'),

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

      this.sendAction('createNewAllocation'); // Calls up to index.js' createAllocation

    },

    showGender: function() {
      this.genderOn();
      this.regionOff();
      this.languageOff();
      this.rankingOff();
    },
    hideGender: function() {
      this.genderOff();
    },
    showRegion: function() {
      this.regionOn();
      this.languageOff();
      this.rankingOff();
      this.genderOff();
    },
    hideRegion: function() {
      this.regionOff();
    },
    showLanguage: function() {
      this.languageOn();
      this.genderOff();
      this.regionOff();
      this.rankingOff();
    },
    hideLanguage: function() {
      this.languageOff();
    },

    showRanking: function() {
      this.rankingOn();
      this.genderOff();
      this.regionOff();
      this.languageOff();
    },
    hideRanking: function() {
      this.rankingOff();
    }
  }

});
