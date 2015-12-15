import Ember from 'ember';

export default Ember.Component.extend({

  sortProperties: ['points:desc'],
  sortedDebates: Ember.computed.sort('model.debates', 'sortProperties'),
  sortAscending: false,
  theFilter: "",

  showingGender: false,
  showingRegion: false,
  showingLanguage: false,

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

  actions: {

    showGender: function() {
      this.set('showingGender', true);
      $(".adjudicator-ui, .debate-team").toggleClass("gender-display");
    },
    hideGender: function() {
      this.set('showingGender', false);
      $(".adjudicator-ui, .debate-team").toggleClass("gender-display");
    },

    showRegion: function() {
      this.set('showingRegion', true);
      $(".adjudicator-ui, .debate-team").toggleClass("region-display");
    },
    hideRegion: function() {
      this.set('showingRegion', false);
      $(".adjudicator-ui, .debate-team").toggleClass("region-display");
    },

    showLanguage: function() {
      this.set('showingLanguage', true);
      $(".adjudicator-ui, .debate-team").toggleClass("language-display");
    },
    hideLanguage: function() {
      this.set('showingLanguage', false);
      $(".adjudicator-ui, .debate-team").toggleClass("language-display");
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
    if (this.get('sortProperties') === "points:asc" || this.get('sortProperties') == "points:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties"),

  sortedByVenue: function() {
    if (this.get('sortProperties') === "venue:asc" || this.get('sortProperties') == "venue:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties"),

  sortedByImportance: function() {
    if (this.get('sortProperties') === "importance:asc" || this.get('sortProperties') == "importance:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties")

});
