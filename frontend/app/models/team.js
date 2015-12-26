import DS from 'ember-data';
import DebateableMixin from '../mixins/debateable';
import Ember from 'ember';

export default DS.Model.extend(DebateableMixin, {

  // Note: gets its base attributes from the debateable mixin
  region: DS.attr('number'), // Teams have singular, adjs have multiple

  points: DS.attr('number'),
  genderdeficit: DS.attr('number'),
  languagedeficit: DS.attr('number'),
  qualitydeficit: DS.attr('number'),
  regionaldeficit: DS.attr('number'),


  // adjHistoryLinear: Ember.computed('adjHistory', function() {
  //   var linearHistory = Array(20); // Hack, should by dynamic
  //   this.get('adjHistory').forEach(function(historyEvent) {
  //     historyEvent.get('rounds').forEach(function(round) {
  //       if (linearHistory[round]) {
  //         linearHistory[round].teamHistories.push(historyEvent);
  //       } else {
  //         linearHistory[round] = {round: round, teamHistories: [historyEvent]};
  //       }
  //     });
  //   });
  //   return linearHistory;
  // }),

  // adjConflictIDs: Ember.computed('adjConflicts', function() {
  //   var adjIDs = [];
  //   this.get('adjConflicts').forEach(function(conflict) {
  //     adjIDs.push(conflict.get('adjudicator').get('id'));
  //   });
  //   return adjIDs;
  // }),

  genderName: Ember.computed('gender', function() { // Teams' genders are different to adjs
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
