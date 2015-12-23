import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({

  chair: DS.belongsTo('adjudicator', { inverse: 'panel' }),
  panellists: DS.hasMany('adjudicator', { inverse: 'panel' }),
  trainees: DS.hasMany('adjudicator', { inverse: 'panel' }),

  debate: DS.belongsTo('debate'),

  allocation: DS.belongsTo('allocation-iteration'),

  // Change these to a single all adjs property
  conflicts: Ember.computed('chair', 'panellists', 'trainees', function() {

    var debateTeams = this.get('debate').get('teams').get('content');

    // Constructing this the labourious way to get around issues merging belongsTo and hasMany
    var debateAdjs = [];
    debateAdjs.push(this.get('chair'));
    this.get('panellists').forEach(function(adj) {
      debateAdjs.push(adj);
    });
    this.get('trainees').forEach(function(adj) {
      debateAdjs.push(adj);
    });

    debateAdjs.forEach(function(debateAdj) {
      debateAdj.set('activePanelTeamConflict', false);
      debateAdj.set('activePanelAdjConflict', false);
      debateAdj.set('activePanelHistoryConflict', false);
      debateAdj.set('activePanelInstitutionConflict', false);
    });

    debateTeams.forEach(function(debateTeam) {
      debateTeam.set('activePanelAdjConflict', false);
      debateTeam.set('activePanelHistoryConflict', false);
      debateTeam.set('activePanelInstitutionConflict', false);
    });

    debateAdjs.forEach(function(debateAdj) {

      // Adj-Team Conflicts
      debateAdj.get('teamConflicts').forEach(function(teamConflict) {
        teamConflict.set('active', false);
        // Get the team object each conflict linkts to
        debateTeams.forEach(function(debateTeam) {
          //console.log('checking ' + teamConflict.get('team'));
          // Check if the conflicted team is in the debate - have to match by ID as object matching not working
          if (debateTeam.get('id') === teamConflict.get('team').get('id')) {
            debateAdj.set('activePanelTeamConflict', true);
            debateTeam.set('activePanelAdjConflict', true);
            teamConflict.set('active', true);
          }
        });
      });

      // Adj-Adj Institutional Conflicts
      debateAdjs.forEach(function(debateAdjAdj) {
        if (debateAdjAdj.get('id') !== debateAdj.get('id')) { // Dur dont match your own institution
          if (debateAdjAdj.get('institution').get('id') === debateAdj.get('institution').get('id')) {
            debateAdj.set('activePanelInstitutionConflict', true);
            debateAdjAdj.set('activePanelInstitutionConflict', true);
          }
        }
      });

      // Adj-Team Institutional Conflicts
      debateTeams.forEach(function(debateTeam) {
        if (debateTeam.get('institution').get('id') === debateAdj.get('institution').get('id')) {
          debateAdj.set('activePanelInstitutionConflict', true);
          debateTeam.set('activePanelInstitutionConflict', true);
        }
      });

      // Adj-Team History Conflicts
      debateAdj.get('teamHistory').forEach(function(historyItem) {
        historyItem.set('active', false);
        // Get the histories of each adjudicator
        //console.log('checking history for ' + debateAdj.get('name') + 'in round ' + round.round);
        //console.log('seen ' + seenTeamsIDs);
        // Check if the each team in the debate has been seen
        debateTeams.forEach(function(debateTeam) {
          if (debateTeam.get('id') === historyItem.get('team').get('id')) {
            debateAdj.set('activePanelHistoryConflict', true);
            historyItem.get('team').set('activePanelHistoryConflict', true);
            historyItem.set('active', true);
          }
        });
      });

      // Adj-Adj Conflicts
      debateAdj.get('adjConflicts').forEach(function(adjConflict) {
        // Get the conflicts of each adjudicator

        adjConflict.set('active', false);
        var conflictingAdj; // ID which adj is the conflictee
        if (adjConflict.get('adj1').get('id') === debateAdj.get('id')) {
          conflictingAdj = adjConflict.get('adj2');
        } else {
          conflictingAdj = adjConflict.get('adj1');
        }

        debateAdjs.forEach(function(debateAdjAgain) {
          // Check if the conflict matches any person on the panel
          if (debateAdjAgain.get('id') === conflictingAdj.get('id')) {
            debateAdj.set('activePanelAdjConflict', true);
            conflictingAdj.set('activePanelAdjConflict', true);
            adjConflict.set('active', true);
          }
        });

      });

      // Adj-Adj History Conflicts
      debateAdj.get('adjHistory').forEach(function(historyItem) {
        // Get the histories of each adjudicator

        historyItem.set('active', false);
        var seenAdj; // ID which adj is the seen adj
        if (historyItem.get('adj1').get('id') === debateAdj.get('id')) {
          seenAdj = historyItem.get('adj2');
        } else {
          seenAdj = historyItem.get('adj1');
        }

        debateAdjs.forEach(function(debateAdjAgain) {
          // Loop through other panellists to check for history matchs
          if (debateAdjAgain.get('id') === seenAdj.get('id')) {
            debateAdj.set('activePanelHistoryConflict', true);
            seenAdj.set('activePanelHistoryConflict', true);
            historyItem.set('active', true);
          }
        });

      });


    });

  }),


  ranking: function() {
    var rankings = [];

    rankings.push(this.get('chair').get('ranking'));

    this.get('panellists').get('content').forEach(function(adj) {
      rankings.push(adj.get('ranking'));
    });

    this.get('trainees').get('content').forEach(function(adj) {
      rankings.push(adj.get('ranking'));
    });

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

