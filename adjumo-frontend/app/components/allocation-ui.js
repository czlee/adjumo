import Ember from 'ember';

export default Ember.Component.extend({

  sortProperties: ['weight:desc'],
  sortedDebates: Ember.computed.sort('model.debates', 'sortProperties'),
  sortAscending: false,
  theFilter: "",

  showingGender: false,
  showingRegion: false,
  showingLanguage: false,
  showingRanking: true,

  checkFilterMatch: function(theObject, searchString) {
    var match = false;
    searchString = searchString.toLowerCase();
    if (theObject.get('venue').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('points').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('importance').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('og').get('content').get('name').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('oo').get('content').get('name').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('cg').get('content').get('name').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('co').get('content').get('name').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    }
    return match;
  },

  filteredDebates: (function() {
    return this.get("sortedDebates").filter((function(_this) {
      return function(theObject, index, enumerable) {
        if (_this.get("theFilter")) {
          // if a filter has been set see if this matches
          return _this.checkFilterMatch(theObject, _this.get("theFilter"));
        } else {
          // else return it (everything will match)
          return true;
        }
      };
    })(this));
  }).property("theFilter", "sortProperties"),

  genderOn: function() {
    this.set('showingGender', true);
    $(".adjudicator-ui, .debate-team").addClass("gender-display");
  },
  genderOff: function() {
    this.set('showingGender', false);
    $(".adjudicator-ui, .debate-team").removeClass("gender-display");
  },
  regionOn: function() {
    this.set('showingRegion', true);
    $(".adjudicator-ui, .debate-team").addClass("region-display");
  },
  regionOff: function() {
    this.set('showingRegion', false);
    $(".adjudicator-ui, .debate-team").removeClass("region-display");
  },
  languageOn: function() {
    this.set('showingLanguage', true);
    $(".adjudicator-ui, .debate-team").addClass("language-display");
  },
  languageOff: function() {
    this.set('showingLanguage', false);
    $(".adjudicator-ui, .debate-team").removeClass("language-display");
  },
  rankingOn: function() {
    this.set('showingRanking', true);
    $(".adjudicator-ui, .debate-team").addClass("ranking-display");
  },
  rankingOff: function() {
    this.set('showingRanking', false);
    $(".adjudicator-ui, .debate-team").removeClass("ranking-display");
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

    sortBy: function(property) {
      this.toggleProperty('sortAscending');
      if (this.get("sortAscending") === true) {
        this.set("sortProperties", [property + ":asc"]);
      } else {
        this.set("sortProperties", [property + ":desc"]);
      }
    }

  },

  sortedByPoints: function() {
    if (this.get('sortProperties') == "points:asc" || this.get('sortProperties') == "points:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties"),

  sortedByVenue: function() {
    if (this.get('sortProperties') == "venue:asc" || this.get('sortProperties') == "venue:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties"),

  sortedByWeight: function() {
    if (this.get('sortProperties') == "weight:asc" || this.get('sortProperties') === "weight:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties"),

  sortedByImportance: function() {
    if (this.get('sortProperties') == "importance:asc" || this.get('sortProperties') == "importance:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties")

});
