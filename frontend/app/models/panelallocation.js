import DS from 'ember-data';

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

    var setTrue = [];
    var setFalse = debateAdjs.concat(debateTeams);

    debateAdjs.forEach(function(debateAdj) {
      debateAdj.set('panelTeamConflict', false);
      debateAdj.set('panelAdjConflict', false);
      debateAdj.set('panelInstitutionConflict', false);
    });

    debateTeams.forEach(function(debateTeam) {
      debateTeam.set('panelTeamConflict', false);
      debateTeam.set('panelAdjConflict', false);
      debateTeam.set('panelInstitutionConflict', false);
    });

    debateAdjs.forEach(function(debateAdj) {

      debateAdj.get('teamConflicts').forEach(function(teamConflict) {
        // Get the team object each conflict linkts to
        var conflictedTeam = teamConflict.get('team');
        debateTeams.forEach(function(debateTeam) {
          //console.log('checking ' + debateTeam.get('name') + ' vs ' + conflictedTeam.get('name'));
          // Check if the conflicted team is in the debate - have to match by ID as object matching not working
          if (debateTeam.get('id') === conflictedTeam.get('id')) {
            debateAdj.set('panelTeamConflict', true);
            conflictedTeam.set('panelTeamConflict', true);
          }
          if (debateTeam.get('institution').get('id') === debateAdj.get('institution').get('id')) {
            debateAdj.set('panelInstitutionConflict', true);
            debateTeam.set('panelInstitutionConflict', true);
          }
        });
      });

      debateAdj.get('adjConflictsWithOutSelf').forEach(function(conflictingAdj) {
        // For each conflict each adj has go through its panellists
        debateAdjs.forEach(function(debateAdjAgain) {
          // Check if the conflict adj matches any person on the panel
          //console.log('checking ' + debateAdj.get('name') + ' vs ' + conflictingAdj.get('name'));
          if (debateAdjAgain.get('id') === conflictingAdj.get('id')) {
            debateAdjAgain.set('panelAdjConflict', true);
            conflictingAdj.set('panelAdjConflict', true);
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

