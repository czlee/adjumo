import DS from 'ember-data';
import DebateableMixin from '../mixins/debateable';
import Ember from 'ember';

export default DS.Model.extend(DebateableMixin, {

  // Note: gets its base attributes from the debateable mixin

  regions: DS.attr(), // Leave blank so it will accept an array
  locked: DS.attr('bool', { defaultValue: false }),
  ranking: DS.attr('number'),
  panel: DS.belongsTo('panelallocation', { inverse: null }),

  lockedTo: DS.belongsTo('debate', { inverse: 'locks' }),
  bannedFrom: DS.hasMany('debate', { inverse: 'bans' }),

  group: DS.belongsTo('group', { inverse: 'groupAdjudicators' }),

  // Only adjudicators have conflicts and histories with each other
  adjAdjConflicts: DS.hasMany('adjudicatorpair', {async: true, inverse: null }), // Need inverse null as multiple possible reversals
  adjAdjHistories: DS.hasMany('adjadjhistory', {async: true, inverse: null }), // Need inverse null as multiple possible reversals

  watchConflicts: Ember.observer('panel', function() {
    Ember.run.once(this, 'calculateConflicts'); // Delays checking to the next run loop; prevents doubling up of checks with set/unsetting
  }),

  calculateConflicts: function() {
    // This will only fire once if you set two properties at the same time, and
    // will also happen in the next run loop once all properties are synchronized
    // console.log('calculating conflicts');

    this.get('panel').then((panel) => {

      if (panel !== null) {         // Seems to be null when stuff is being set/unset?
        var debateAdjs = panel.get('panellists');
        var debateAdjs = [];
        if (panel.get('chair').get('content') !== null ) { debateAdjs.push(panel.get('chair')); }
        if (panel.get('panellists').get('length') > 0 ) { panel.get('panellists').forEach(function(adj) { debateAdjs.push(adj); });}
        if (panel.get('trainees').get('length') > 0 ) { panel.get('trainees').forEach(function(adj) { debateAdjs.push(adj);});}

        panel.get('debate').then((debate) => {

          var debateTeams = debate.get('teams');
          debateAdjs.forEach(function(adjudicator) {

            // ADJ TEAM CONFLICTS
            if (adjudicator.get('teamAdjConflicts') !== undefined) {
              adjudicator.get('teamAdjConflicts').forEach(function(conflict) {

                var hasConflict = false;
                debateTeams.forEach(function(debateTeam) {  // Loop through all the teams and check if they match
                  if (debateTeam.get('id') === conflict.get('team').get('id')) {
                    hasConflict = true;
                    //console.log('      setting active team adj conflict ' + adjudicator.get('name') + ' vs ' + adjConflict.get('team').get('name'));
                  }
                });
                conflict.set('panelActive', hasConflict);
              });
            }

            // ADJ ADJ CONFLICTS
            if (adjudicator.get('adjAdjConflicts') !== undefined) {
              adjudicator.get('adjAdjConflicts').forEach(function(conflict) {
                var conflictingAdj;
                if (conflict.get('adj1').get('id') === adjudicator.get('id')) {
                  conflictingAdj = conflict.get('adj2');
                } else {
                  conflictingAdj = conflict.get('adj1');
                }
                var hasConflict = false;
                debateAdjs.forEach(function(debateAdjudicator) {  // Loop through all the teams and check if they match
                  if (debateAdjudicator.get('id') === conflictingAdj.get('id')) {
                    hasConflict = true;
                    //console.log('      setting active adj adj conflict ' + adjudicator.get('name') + ' vs ' + conflictingAdj.get('name'));
                  }
                });
                conflict.set('panelActive', hasConflict);
              });
            }

            // ADJ TEAM HISTORIES
            if (adjudicator.get('teamAdjHistories') !== undefined) {
              adjudicator.get('teamAdjHistories').forEach(function(history) {
                var hasHistory = false;
                debateTeams.forEach(function(debateTeam) {  // Loop through all the teams and check if they match
                  if (debateTeam.get('id') === history.get('team').get('id')) {
                    hasHistory = true;
                    // /console.log('      setting active team adj history ' + adjudicator.get('name') + ' vs ' + history.get('team').get('name'));
                  }
                });
                history.set('panelActive', hasHistory);
              });
            }

            // ADJ ADJ HISTORIES
            if (adjudicator.get('adjAdjHistories') !== undefined) {
              adjudicator.get('adjAdjHistories').forEach(function(history) {
                var conflictingAdj;
                if (history.get('adj1').get('id') === adjudicator.get('id')) {
                  conflictingAdj = history.get('adj2');
                } else {
                  conflictingAdj = history.get('adj1');
                }
                var hasHistory = false;
                debateAdjs.forEach(function(debateAdjudicator) {  // Loop through all the teams and check if they match
                  if (debateAdjudicator.get('id') === conflictingAdj.get('id')) {
                    hasHistory = true;
                    //console.log('      setting active adj adj history ' + adjudicator.get('name') + ' vs ' + conflictingAdj.get('name'));
                  }
                });
                history.set('panelActive', hasHistory);
              });
            }

            // DO THIS so each conflict type has a fresh slate
            debateTeams.forEach(function(debateTeam) {
              debateTeam.set('hasInstitutionalConflict', false);
            });
            adjudicator.set('hasInstitutionalConflict', false);

            // ADJ TEAM INSTITUTIONS
            debateTeams.forEach(function(debateTeam) {  // Loop through all the teams and check if they match
              if (debateTeam.get('institution').get('id') === adjudicator.get('institution').get('id')) {
                if (!adjudicator.get('hasInstitutionalConflict')) {
                  adjudicator.set('hasInstitutionalConflict', true);
                }
                if (!debateTeam.get('hasInstitutionalConflict')) {
                  debateTeam.set('hasInstitutionalConflict', true);
                }
                //console.log('      setting active instituon team conflict ' + adjudicator.get('name') + ' vs ' + debateTeam.get('name'));
              }
            });

            //ADJ ADJ INSTITUTIONS
            debateAdjs.forEach(function(debateAdjudicator) {  // Loop through all the teams and check if they match
              if (debateAdjudicator.get('id') !== adjudicator.get('id')) {
                if (debateAdjudicator.get('institution').get('id') === adjudicator.get('institution').get('id')) {
                  if (!debateAdjudicator.get('hasInstitutionalConflict')) {
                    debateAdjudicator.set('hasInstitutionalConflict', true);
                  }
                  if (!adjudicator.get('hasInstitutionalConflict')) {
                    adjudicator.set('hasInstitutionalConflict', true);
                  }
                  //console.log('      setting active instituon adj conflict ' + adjudicator.get('name') + ' vs ' + debateAdjudicator.get('name'));
                }
              }
            });

          });

        });
      }


    });

  },


  short_name: Ember.computed('name', function() {
    var words = this.get('name').split(" ");
    if (words[1] !== undefined) {
      return words[0] + " " + words[1][0]; // If they only have a first name in the system
    } else {
      return words[0];
    }

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
