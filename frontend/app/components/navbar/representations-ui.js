import Ember from 'ember';

export default Ember.Component.extend({

  showingGender: false,
  showingRegion: false,
  showingLanguage: false,
  showingRanking: false,

  genderOn: function() {
    this.set('showingGender', true);
    $(".adjudicator-ui, .team-ui").addClass("gender-display");
    $(".debate-gender-deficits").show();
  },
  genderOff: function() {
    this.set('showingGender', false);
    $(".adjudicator-ui, .team-ui").removeClass("gender-display");
    $(".debate-gender-deficits").hide();
  },
  regionOn: function() {
    this.set('showingRegion', true);
    $(".adjudicator-ui, .team-ui").addClass("region-display");
    $(".debate-regional-deficits").show();
  },
  regionOff: function() {
    this.set('showingRegion', false);
    $(".adjudicator-ui, .team-ui").removeClass("region-display");
    $(".debate-regional-deficits").hide();
  },
  languageOn: function() {
    this.set('showingLanguage', true);
    $(".adjudicator-ui, .team-ui").addClass("language-display");
    $(".debate-language-deficits").show();
  },
  languageOff: function() {
    this.set('showingLanguage', false);
    $(".adjudicator-ui, .team-ui").removeClass("language-display");
    $(".debate-language-deficits").hide();
  },
  rankingOn: function() {
    this.set('showingRanking', true);
    $(".adjudicator-ui, .debate-ui").addClass("ranking-display");
    $(".debate-quality-deficits").show();
  },
  rankingOff: function() {
    this.set('showingRanking', false);
    $(".adjudicator-ui, .debate-ui").removeClass("ranking-display");
    $(".debate-quality-deficits").hide();
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
