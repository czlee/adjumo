import Ember from 'ember';

export default Ember.Component.extend({

  showingGender: false,
  showingRegion: false,
  showingLanguage: false,
  showingRanking: false,

  genderOn: function() {
    this.set('showingGender', true);
    $(".adjudicator-ui, .team-ui").addClass("gender-display");
  },
  genderOff: function() {
    this.set('showingGender', false);
    $(".adjudicator-ui, .team-ui").removeClass("gender-display");
  },
  regionOn: function() {
    this.set('showingRegion', true);
    $(".adjudicator-ui, .team-ui").addClass("region-display");
  },
  regionOff: function() {
    this.set('showingRegion', false);
    $(".adjudicator-ui, .team-ui").removeClass("region-display");
  },
  languageOn: function() {
    this.set('showingLanguage', true);
    $(".adjudicator-ui, .team-ui").addClass("language-display");
  },
  languageOff: function() {
    this.set('showingLanguage', false);
    $(".adjudicator-ui, .team-ui").removeClass("language-display");
  },
  rankingOn: function() {
    this.set('showingRanking', true);
    $(".adjudicator-ui, .preallocation.debate-importance, .allocation.debate-importance").addClass("ranking-display");
  },
  rankingOff: function() {
    this.set('showingRanking', false);
    $(".adjudicator-ui, .preallocation.debate-importance, .allocation.debate-importance").removeClass("ranking-display");
  },

  actions: {

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
    },

  }

});
