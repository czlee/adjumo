import Ember from 'ember';

export default Ember.Component.extend({

  sortProperties: ['points:desc'],
  sortedDebates: Ember.computed.sort('model.debates', 'sortProperties'),
  sortAscending: false,

  actions: {

    toggleGender: function() {
      console.log("Toggling adj");
    },

    sortBy: function(property) {
      this.toggleProperty('sortAscending');
      this.set("sortProperties", [property]);
    }

  },

  sortedByPoints: function() {
    if (this.get('sortProperties') == "points") { return true; } else { return false; }
  }.property("sortProperties"),

  sortedByVenue: function() {
    if (this.get('sortProperties') == "venue") { return true; } else { return false; }
  }.property("sortProperties"),

  sortedByImportance: function() {
    if (this.get('sortProperties') == "importance") { return true; } else { return false; }
  }.property("sortProperties")

});
