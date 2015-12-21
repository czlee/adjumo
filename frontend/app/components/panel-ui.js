import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  actions: {

    checkConflicts: function(droppedAdj) {
      console.log('got adj');

      var droppedAdjID = droppedAdj.get('id');

      var debateAdjs = Ember.merge(this.get('panel').get('panellists'), this.get('panel').get('trainees'));
      debateAdjs.forEach(function(adj) {
        // Reset from previous panel's state (we run over everything again as there's no reliable way to remove multiple conflicts individually)
        adj.set('panelTeamConflict', false);
        adj.set('panelAdjConflict', false);
        adj.set('panelInstitutionalConflict', false);
      });

      // Use an array of IDs for checking
      var debateTeams = this.get('panel').get('debate').get('teams').get('content');
      debateTeams.forEach(function(team) {
        // Reset from previous panel's state
        team.set('panelTeamConflict', false);
        team.set('panelAdjConflict', false);
        team.set('panelInstitutionalConflict', false);
      });

      debateAdjs.forEach(function(debateAdj) {

        debateAdj.get('teamConflicts').forEach(function(teamConflict) {
          // Get the team object each conflict linkts to
          var conflictedTeam = teamConflict.get('team');

          debateTeams.forEach(function(debateTeam) {
            // Check if the conflicted team is in the debate - have to match by ID as object matching not working
            if (debateTeam.get('id') === conflictedTeam.get('id')) {
              debateAdj.set('panelTeamConflict', true);
              conflictedTeam.set('panelTeamConflict', true);
            }
          });
        });

        debateAdj.get('adjConflictsWithOutSelf').forEach(function(conflictingAdj) {
          // For each conflict each adj has go through its panellists
          debateAdjs.forEach(function(debateAdjAgain) {
            // Check if the conflict adj matches any person on the panel
            if (debateAdjAgain.get('id') === conflictingAdj.get('id')) {
              debateAdj.set('panelAdjConflict', true);
              conflictingAdj.set('panelAdjConflict', true);
            }
          });
        });

        // Institution conflict checking TODO

      });



    }
  }

});
