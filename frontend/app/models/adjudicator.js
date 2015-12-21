import DS from 'ember-data';
import DebateableMixin from '../mixins/debateable';

export default DS.Model.extend(DebateableMixin, {

  // Note: gets its base attributes from the debateable mixin

  regions: DS.attr(), // Leave blank so it will accept an array
  locked: DS.attr('bool', { defaultValue: false }),
  ranking: DS.attr('number'),
  panel: DS.belongsTo('panelallocation', { inverse: null }),

  teamConflicts: DS.hasMany('teamadjudicator', {async: true}),
  adjConflicts: DS.hasMany('adjudicatorpair', {async: true, inverse: null }),

  teamHistory: DS.hasMany('teamadjhistory', {async: true}),

  teamHistoryLinear: Ember.computed('teamHistory', function() {
    var linearHistory = Array(20); // Hack, should by dynamic
    this.get('teamHistory').forEach(function(history) {
      history.get('rounds').forEach(function(round) {
        if (linearHistory[round]) {
          linearHistory[round].teams.push(history.get('team'));
        } else {
          linearHistory[round] = {round: round, teams: [history.get('team')]};
        }
      });
    });
    return linearHistory;
  }),

  hasConflicts: Ember.computed('teamConflicts', 'adjConflicts', function() {
    var conflicts = this.get('teamConflicts').get('content').length;
    conflicts += this.get('adjConflicts').get('content').length;
    return conflicts; // 0 = false
  }),

  adjConflictsWithOutSelf: Ember.computed('adjConflicts', function() {
    var adjs = [];
    var thisAdjID = this.get('id');
    this.get('adjConflicts').forEach(function(conflict) {
      if (conflict.get('adj1').get('id') === thisAdjID) {
        adjs.push(conflict.get('adj2'));
      } else {
        adjs.push(conflict.get('adj1'));
      }
    });
    return adjs;
  }),

  adjConflictIDs: Ember.computed('adjConflicts', function() {
    var adjIDs = [];
    var thisAdjID = this.get('id');
    this.get('adjConflicts').forEach(function(conflict) {
      if (conflict.get('adj1').get('id') === thisAdjID) {
        adjIDs.push(conflict.get('adj2').get('id'));
      } else {
        adjIDs.push(conflict.get('adj1').get('id'));
      }
    });
    return adjIDs;
  }),

  teamConflictIDs: Ember.computed('teamConflicts', function() {
    var teamIDs = [];
    this.get('teamConflicts').forEach(function(conflict) {
      teamIDs.push(conflict.get('team').get('id'));
    });
    return teamIDs;
  }),

  // listConflictsNames: Ember.computed('teamConflicts', function() {
  //   this.get('teamConflicts').objectAt(0);
  // }),

  short_name: Ember.computed('name', function() {
    var words = this.get('name').split(" ");
    var short_name = words[0] + " " + words[1][0];
    return short_name;
  }),

  genderName: Ember.computed('gender', function() {
    var gender = this.get('gender');
    if (gender === 0) {
      return "None";
    } else if (gender === 1){
      return "Male";
    } else if (gender === 2){
      return "Female";
    } else if (gender === 3){
      return "Other";
    } else {
      return "?";
    }
  }),

  get_ranking: function() {
    var ranking_word = "";
    if (this.get('ranking') <= 2) {
      ranking_word = "T";
      if (this.get('ranking') == 0) {
        ranking_word += "-";
      }
      else if (this.get('ranking') == 2) {
        ranking_word += "+";
      }
    } else if (this.get('ranking') <= 5) {
      ranking_word = "P";
      if (this.get('ranking') == 3) {
        ranking_word += "-";
      }
      else if (this.get('ranking') == 5) {
        ranking_word += "+";
      }
    } else if (this.get('ranking') <= 8) {
      ranking_word = "C";
      if (this.get('ranking') == 6) {
        ranking_word += "-";
      }
      else if (this.get('ranking') == 8) {
        ranking_word += "+";
      }
    }
    return ranking_word;
  }.property('ranking'),

});
