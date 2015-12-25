import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({

  chair: DS.belongsTo('adjudicator', { inverse: 'panel' }),
  panellists: DS.hasMany('adjudicator', { inverse: 'panel' }),
  trainees: DS.hasMany('adjudicator', { inverse: 'panel' }),

  debate: DS.belongsTo('debate'),

  allocation: DS.belongsTo('allocation-iteration'),
  allocationID: DS.attr('number'),

  score: DS.attr('number'),

  allTeams: Ember.computed('debate', function() {
    return this.get('debate').get('teams');
  }),

  allAdjudicators: Ember.computed('chair', 'panellists', 'trainees', function() {

    var debateAdjs = [];
    debateAdjs.push(this.get('chair'));
    this.get('panellists').forEach(function(adj) {
      debateAdjs.push(adj);
    });
    this.get('trainees').forEach(function(adj) {
      debateAdjs.push(adj);
    });
    return debateAdjs;

  }),

  // Change these to a single all adjs property
  conflicts: Ember.computed('chair', 'panellists', 'trainees', function() {

    // console.log('conflicts computed updated');

    var debateTeams = this.get('debate').get('teams').get('content');

    // Constructing this the labourious way to get around issues merging belongsTo and hasMany
    var debateAdjs = this.get('allAdjudicators');

    // debateAdjs.forEach(function(debateAdj) {
    //   debateAdj.set('temporaryActivePanelTeamConflict', false);
    //   debateAdj.set('temporaryActivePanelAdjConflict', false);
    //   debateAdj.set('temopraryActivePanelHistoryConflict', false);
    //   debateAdj.set('temporaryActivePanelInstitutionConflict', false);
    // });

    // debateTeams.forEach(function(debateTeam) {
    //   debateTeam.set('temporaryActivePanelAdjConflict', false);
    //   debateTeam.set('temopraryActivePanelHistoryConflict', false);
    //   debateTeam.set('temporaryActivePanelInstitutionConflict', false);
    // });

    // debateAdjs.forEach(function(debateAdj) {

    //   // Adj-Team Conflicts
    //   debateAdj.get('teamConflicts').forEach(function(teamConflict) {
    //     // teamConflict.set('active', false);
    //     // Get the team object each conflict linkts to
    //     debateTeams.forEach(function(debateTeam) {
    //       //console.log('checking ' + teamConflict.get('team'));
    //       // Check if the conflicted team is in the debate - have to match by ID as object matching not working
    //       if (debateTeam.get('id') === teamConflict.get('team').get('id')) {
    //         debateAdj.set('temporaryActivePanelTeamConflict', true);
    //         debateTeam.set('temporaryActivePanelAdjConflict', true);
    //         //conflictsToSetActive.push(teamConflict);
    //       }
    //     });
    //   });

    //   // Adj-Adj Institutional Conflicts
    //   debateAdjs.forEach(function(debateAdjAdj) {
    //     if (debateAdjAdj.get('id') !== debateAdj.get('id')) { // Dur dont match your own institution
    //       if (debateAdjAdj.get('institution').get('id') === debateAdj.get('institution').get('id')) {
    //         debateAdj.set('temporaryActivePanelInstitutionConflict', true);
    //         debateAdjAdj.set('temporaryActivePanelInstitutionConflict', true);
    //       }
    //     }
    //   });

    //   // Adj-Team Institutional Conflicts
    //   debateTeams.forEach(function(debateTeam) {
    //     if (debateTeam.get('institution').get('id') === debateAdj.get('institution').get('id')) {
    //       debateAdj.set('temporaryActivePanelInstitutionConflict', true);
    //       debateTeam.set('temporaryActivePanelInstitutionConflict', true);
    //     }
    //   });

    //   // Adj-Team History Conflicts
    //   debateAdj.get('teamHistory').forEach(function(historyItem) {
    //     // historyItem.set('active', false);
    //     // Get the histories of each adjudicator
    //     //console.log('checking history for ' + debateAdj.get('name') + 'in round ' + round.round);
    //     //console.log('seen ' + seenTeamsIDs);
    //     // Check if the each team in the debate has been seen
    //     debateTeams.forEach(function(debateTeam) {
    //       if (debateTeam.get('id') === historyItem.get('team').get('id')) {
    //         debateAdj.set('temopraryActivePanelHistoryConflict', true);
    //         historyItem.get('team').set('temopraryActivePanelHistoryConflict', true);
    //         //conflictsToSetActive.push(historyItem);
    //       }
    //     });
    //   });

    //   // Adj-Adj Conflicts
    //   // debateAdj.get('adjConflicts').forEach(function(adjConflict) {
    //   //   // Get the conflicts of each adjudicator

    //   //   // adjConflict.set('active', false);
    //   //   var conflictingAdj; // ID which adj is the conflictee
    //   //   if (adjConflict.get('adj1').get('id') === debateAdj.get('id')) {
    //   //     conflictingAdj = adjConflict.get('adj2');
    //   //   } else {
    //   //     conflictingAdj = adjConflict.get('adj1');
    //   //   }

    //   //   debateAdjs.forEach(function(debateAdjAgain) {
    //   //     // Check if the conflict matches any person on the panel
    //   //     if (debateAdjAgain.get('id') === conflictingAdj.get('id')) {
    //   //       debateAdj.set('temporaryActivePanelAdjConflict', true);
    //   //       conflictingAdj.set('temporaryActivePanelAdjConflict', true);
    //   //       //conflictsToSetActive.push(adjConflict);
    //   //     }
    //   //   });

    //   // });

    //   // Adj-Adj History Conflicts
    //   debateAdj.get('adjHistory').forEach(function(historyItem) {
    //     // Get the histories of each adjudicator

    //     var seenAdj; // ID which adj is the seen adj
    //     if (historyItem.get('adj1').get('id') === debateAdj.get('id')) {
    //       seenAdj = historyItem.get('adj2');
    //     } else {
    //       seenAdj = historyItem.get('adj1');
    //     }

    //     debateAdjs.forEach(function(debateAdjAgain) {
    //       // Loop through other panellists to check for history matchs
    //       if (debateAdjAgain.get('id') === seenAdj.get('id')) {
    //         debateAdj.set('temopraryActivePanelHistoryConflict', true);
    //         seenAdj.set('temopraryActivePanelHistoryConflict', true);
    //         //conflictsToSetActive.push(adjConflict);
    //       }
    //     });

    //   });

    //   // Loop through this list of avoid setting things twice
    //   // //conflictsToSetActive.forEach(function(conflict) {
    //   //   //conflict.set('active', true);
    //   // });


    // });

  }),

  ranking: function() {
    var rankings = [];

    if (this.get('chair').get('ranking') !== undefined) {
        rankings.push(this.get('chair').get('ranking'));
    }
    if (this.get('panellists').get('length') > 0) {
        this.get('panellists').forEach(function(adj) {
          rankings.push(adj.get('ranking'));
        });
    }
    if (this.get('trainees').get('length') > 0) {
        this.get('trainees').forEach(function(adj) {
          rankings.push(adj.get('ranking'));
        });
    }

    var sum = 0;
    for( var i = 0; i < rankings.length; i++ ){
      sum += parseInt( rankings[i], 10 ); //don't forget to add the base
    }
    var avg = sum/rankings.length;

    if (avg) {
      return Math.round(avg * 10) / 10;
    } else {
      return 0;
    }

  }.property('chair', 'panellists', 'trainees')

});

