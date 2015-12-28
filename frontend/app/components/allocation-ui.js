import Ember from 'ember';

export default Ember.Component.extend({

  sortProperties: ['weight:desc'],
  sortedDebates: Ember.computed.sort('debates', 'sortProperties'),
  sortAscending: false,
  theFilter: "",

  store: Ember.inject.service(), // For adding new groups to the store

  checkFilterMatch: function(theObject, searchString) {
    var match = false;
    searchString = searchString.toLowerCase();
    if (theObject.get('venue') !== undefined && theObject.get('venue').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('points') !== undefined && theObject.get('points').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('importance').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('teams').objectAt(0).get('name').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('teams').objectAt(1).get('name').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('teams').objectAt(2).get('name').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    } else if (theObject.get('teams').objectAt(3).get('name').toString().toLowerCase().slice(0, searchString.length) === searchString) {
      match = true;
    }
    return match;
  },

  filteredDebates: (function() {
    return this.get("sortedDebates").filter((function(_this) {
      return function(theObject) {
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

    sortBy: function(property) {
      this.toggleProperty('sortAscending');
      if (this.get("sortAscending") === true) {
        this.set("sortProperties", [property + ":asc"]);
      } else {
        this.set("sortProperties", [property + ":desc"]);
      }
    },

    createNewAllocation: function() {
      this.sendAction('createNewAllocation');
    },

    checkWhetherToAddNewGroups: function() {

      var store = this.get('store'); // Reference the service injection at the top

      store.findAll('group').then((groups) => {
        var fullGroups = 0;
        var numberOfCurrentGroups = groups.get('length');

        groups.forEach(function(group) {
          if (group.get('groupAdjudicators').get('content').length > 1) {
            fullGroups+= 1;
          }
        });

        if (fullGroups === numberOfCurrentGroups) {
          // If full we push two new rows to the table to be filled
          store.createRecord('group', { id: numberOfCurrentGroups + 1 });
          store.createRecord('group', { id: numberOfCurrentGroups + 2 });
        }

      });

    },

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
    if (this.get('sortProperties') == "weight:asc" || this.get('sortProperties') == "weight:desc") {
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
  }.property("sortProperties"),

  sortedByQualityDeficit: function() {
    if (this.get('sortProperties') == "qualityDeficit:asc" || this.get('sortProperties') == "qualityDeficit:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties"),

  sortedByGenderDeficit: function() {
    if (this.get('sortProperties') == "genderDeficit:asc" || this.get('sortProperties') == "genderDeficit:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties"),

  sortedByLanguageDeficit: function() {
    if (this.get('sortProperties') == "languageDeficit:asc" || this.get('sortProperties') == "languageDeficit:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties"),

  sortedByRegionalDeficit: function() {
    if (this.get('sortProperties') == "regionalDeficit:asc" || this.get('sortProperties') == "regionalDeficit:desc") {
      return true;
    } else {
      return false;
    }
  }.property("sortProperties"),

  didInsertElement: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      this.$('[data-toggle="tooltip"]').tooltip();
    });
  }

});
