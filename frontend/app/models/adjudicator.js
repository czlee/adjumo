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

  calculateConflicts: Ember.observer('panel', function() {

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
  }),


  // partOfTeamAdjConflictsChanged: Ember.observer('panel.chair', 'panel.trainees', 'panel.panellists', function() {
  //   Ember.run.once(this, 'checkTeamAdjConflicts');
  // }),

  // checkTeamAdjConflicts: Ember.observer('panel.chair', 'panel.trainees', 'panel.panellists', function() {
  //   var debateTeams = this.get('panel').get('allTeams');
  //   var theAdj = this;

  //   if (debateTeams !== undefined) {
  //     // Not being droped to unused
  //     // console.log('    checking team adj conflict for ' + this.get('name'));
  //     this.get('teamAdjConflicts').forEach(function(adjConflict) {
  //       // console.log('    option 1 ' + adjConflict.get('adj1').get('name'));
  //       // console.log('    option 2 ' + adjConflict.get('adj2').get('name'));
  //       // Loop through all their conflicts
  //       debateTeams.forEach(function(debateTeam) {
  //         //console.log('   checking for conflicting adj vs' + debateAdj.get('name'));
  //         // Loop through all their fellow panellists and check if they match
  //         if (debateTeam.get('id') === adjConflict.get('team').get('id')) {
  //           console.log('      setting active conflict ' + theAdj.get('name') + ' vs ' + adjConflict.get('team').get('name'));
  //           adjConflict.set('panelActive', true);
  //         } else {
  //           //console.log('      setting inactive conflict vs ' + conflictingAdj.get('name'));
  //           adjConflict.set('panelActive', false);
  //         }
  //       });
  //     });
  //   } else {
  //     this.get('adjAdjConflicts').forEach(function(adjConflict) {
  //       // Being dropped to the unused area
  //       adjConflict.set('panelActive', false);
  //     });
  //   }
  // }),

  // checkAdjAdjConflicts: Ember.observer('panel', function() {
  //   var thisAdjudicator = this;
  //   var debateAdjudicators = this.get('panel').get('allAdjudicators');

  //   if (debateAdjudicators !== undefined) {
  //     // Not being droped to unused
  //     console.log('    checking adj adj conflict for ' + thisAdjudicator.get('name'));
  //     this.get('adjAdjConflicts').forEach(function(adjConflict) {
  //       // console.log('    option 1 ' + adjConflict.get('adj1').get('name'));
  //       // console.log('    option 2 ' + adjConflict.get('adj2').get('name'));
  //       // Loop through all their conflicts
  //       var conflictingAdj; // ID which adj is the conflictee
  //       if (adjConflict.get('adj1').get('id') === thisAdjudicator.get('id')) {
  //         conflictingAdj = adjConflict.get('adj2');
  //       } else {
  //         conflictingAdj = adjConflict.get('adj1');
  //       }
  //       debateAdjudicators.forEach(function(debateAdj) {
  //         //console.log('   checking for conflicting adj vs' + debateAdj.get('name'));
  //         // Loop through all their fellow panellists and check if they match
  //         if (debateAdj.get('id') === conflictingAdj.get('id')) {
  //           console.log('      setting active conflict vs ' + conflictingAdj.get('name'));
  //           adjConflict.set('panelActive', true);
  //         } else {
  //           //console.log('      setting inactive conflict vs ' + conflictingAdj.get('name'));
  //           adjConflict.set('panelActive', false);
  //         }
  //       });
  //     });
  //   } else {
  //     this.get('adjAdjConflicts').forEach(function(adjConflict) {
  //       // Being dropped to the unused area
  //       adjConflict.set('panelActive', false);
  //     });
  //   }
  // }),

  // checkAdjAdjHistories: Ember.observer('panel.chair', 'panel.trainees', 'panel.panellists', function() {
  //   var thisAdjudicator = this;
  //   var debateAdjudicators = this.get('panel').get('allAdjudicators');

  //   if (debateAdjudicators !== undefined) {
  //     // Not being droped to unused
  //     console.log('    checking adj adj history for ' + thisAdjudicator.get('name'));
  //     this.get('adjAdjHistories').forEach(function(adjConflict) {
  //       // console.log('    option 1 ' + adjConflict.get('adj1').get('name'));
  //       // console.log('    option 2 ' + adjConflict.get('adj2').get('name'));
  //       // Loop through all their conflicts
  //       var conflictingAdj; // ID which adj is the conflictee
  //       if (adjConflict.get('adj1').get('id') === thisAdjudicator.get('id')) {
  //         conflictingAdj = adjConflict.get('adj2');
  //       } else {
  //         conflictingAdj = adjConflict.get('adj1');
  //       }
  //       debateAdjudicators.forEach(function(debateAdj) {
  //         //console.log('   checking for conflicting adj vs' + debateAdj.get('name'));
  //         // Loop through all their fellow panellists and check if they match
  //         if (debateAdj.get('id') === conflictingAdj.get('id')) {
  //           console.log('      setting active history vs ' + conflictingAdj.get('name'));
  //           adjConflict.set('panelActive', true);
  //         } else {
  //           //console.log('      setting inactive conflict vs ' + conflictingAdj.get('name'));
  //           adjConflict.set('panelActive', false);
  //         }
  //       });
  //     });
  //   } else {
  //     this.get('adjAdjHistories').forEach(function(adjConflict) {
  //       // Being dropped to the unused area
  //       adjConflict.set('panelActive', false);
  //     });
  //   }
  // }),

  // watchPanelTeamConflict: Ember.computed('teamConflicts.@each.panelActive', function() {
  //   // Whenever a conflict has its active status changed return false
  //   if (this.get('teamConflicts').filterBy('panelActive', true).get('length') > 0) {
  //     console.log('fetching true active activePanelTeamConflict');
  //     return true;
  //   } else {
  //     console.log('fetching false active activePanelTeamConflict');
  //     return false;
  //   }
  // }),


  // // ADJ-ADJ CONFLICTS
  // activePanelAdjConflict: Ember.computed('adjConflicts.@each.panelActive', function() {
  //   // Whenever a conflict has its active status changed return false
  //   if (this.get('adjConflicts').filterBy('panelActive', true).get('length') > 0) {
  //     console.log('fetching true active activePanelAdjConflict');
  //     return true;
  //   } else {
  //     console.log('fetching false active activePanelAdjConflict');
  //     return false;
  //   }
  // }),

  // adjHistoryLinear: Ember.computed('adjHistory', function() {
  //   var linearHistory = Array(20); // Hack, should by dynamic
  //   var thisAdjID = this.get('id');

  //   this.get('adjHistory').forEach(function(historyEvent) {

  //     // Need to figure out which person is being conflicted with
  //     var conflictingAdj;
  //     if (historyEvent.get('adj1').get('id') === thisAdjID) {
  //       conflictingAdj = historyEvent.get('adj2');
  //     } else {
  //       conflictingAdj = historyEvent.get('adj1');
  //     }
  //     historyEvent.get('rounds').forEach(function(round) {
  //       if (linearHistory[round]) {
  //         linearHistory[round].historyWrapper.push({ conflictingAdj: conflictingAdj, adjadjhistory: historyEvent});
  //       } else {
  //         linearHistory[round] = {round: round, historyWrapper: [{ conflictingAdj: conflictingAdj, adjadjhistory: historyEvent}]};
  //       }
  //     });

  //   });
  //   return linearHistory;
  // }),

  // teamHistoryLinear: Ember.computed('teamHistory', function() {
  //   var linearHistory = Array(20); // Hack, should by dynamic
  //   this.get('teamHistory').forEach(function(historyEvent) {
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
  //   var thisAdjID = this.get('id');
  //   this.get('adjConflicts').forEach(function(conflict) {
  //     if (conflict.get('adj1').get('id') === thisAdjID) {
  //       adjIDs.push(conflict.get('adj2').get('id'));
  //     } else {
  //       adjIDs.push(conflict.get('adj1').get('id'));
  //     }
  //   });
  //   return adjIDs;
  // }),

  // teamConflictIDs: Ember.computed('teamConflicts', function() {
  //   var teamIDs = [];
  //   this.get('teamConflicts').forEach(function(conflict) {
  //     teamIDs.push(conflict.get('team').get('id'));
  //   });
  //   return teamIDs;
  // }),

  // listConflictsNames: Ember.computed('teamConflicts', function() {
  //   this.get('teamConflicts').objectAt(0);
  // }),

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
