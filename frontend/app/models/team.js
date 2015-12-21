import DS from 'ember-data';
import DebateableMixin from '../mixins/debateable';

export default DS.Model.extend(DebateableMixin, {

  // Note: gets its base attributes from the debateable mixin
  region: DS.attr('number'), // Teams have singular, adjs have multiple

  adjConflicts: DS.hasMany('teamadjudicator', {async: true}),

  adjConflictIDs: Ember.computed('adjConflicts', function() {
    var adjIDs = [];
    this.get('adjConflicts').forEach(function(conflict) {
      adjIDs.push(conflict.get('adjudicator').get('id'));
    });
    return adjIDs;
  }),

  genderName: Ember.computed('gender', function() {
    var gender = this.get('gender');
    if (gender === 0) {
      return "None";
    } else if (gender === 1){
      return "2 Males";
    } else if (gender === 2){
      return "2 Females";
    } else if (gender === 3){
      return "Mixed Gender";
    } else {
      return "Unknown";
    }
  }),

});
