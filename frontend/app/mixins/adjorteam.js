import Ember from 'ember';

export default Ember.Mixin.create({

  classNameBindings: [
    'gender', 'region', 'language', 'id', 'institution',
    'panelHistoryConflict', 'panelTeamConflict', 'panelAdjConflict', 'panelInstitutionConflict',
    'hoverHistoryConflict', 'hoverTeamConflict', 'hoverAdjConflict', 'hoverInstitutionConflict',
  ],

  // CSS Getters
  gender: function(){
    return 'gender-' + String(this.get('adjorTeam').get('gender'));
  }.property('adjorTeam'),

  region: function() {
    return 'region-' + String(this.get('adjorTeam').get('region'));
  }.property('adjorTeam'),

  language: function() {
    return 'language-' + String(this.get('adjorTeam').get('language'));
  }.property('adjorTeam'),

  institution: function() {
    return 'institution-' + String(this.get('adjorTeam').get('institution').get('id'));
  }.property('adjorTeam'),

  id: function() {
    return 'team-' + String(this.get('adjorTeam').get('id'));
  }.property('id'),

  panelHistoryConflict: function() {
    if (this.get('adjorTeam').get('activePanelHistoryConflict') === true) {
      return 'panel-history-conflict';
    }
  }.property('adjorTeam.activePanelHistoryConflict'),
  panelTeamConflict: function() {
    if (this.get('adjorTeam').get('activePanelTeamConflict') === true) {
      return 'panel-team-conflict';
    }
  }.property('adjorTeam.activePanelTeamConflict'),
  panelAdjConflict: function() {
    if (this.get('adjorTeam').get('activePanelAdjConflict') === true) {
      return 'panel-adj-conflict';
    }
  }.property('adjorTeam.activePanelAdjConflict'),
  panelInstitutionConflict: function() {
    if (this.get('adjorTeam').get('activePanelInstitutionConflict') === true) {
      return 'panel-institution-conflict';
    }
  }.property('adjorTeam.activePanelInstitutionConflict'),

  hoverHistoryConflict: function() {
    if (this.get('adjorTeam').get('activeHoveringHistoryConflict') === true) {
      return 'hover-history-conflict';
    }
  }.property('adjorTeam.activeHoveringHistoryConflict'),
  hoverTeamConflict: function() {
    if (this.get('adjorTeam').get('activeHoveringTeamConflict') === true) {
      return 'hover-team-conflict';
    }
  }.property('adjorTeam.activeHoveringTeamConflict'),
  hoverAdjConflict: function() {
    if (this.get('adjorTeam').get('activeHoverAdjConflict') === true) {
      return 'hover-adj-conflict';
    }
  }.property('adjorTeam.activeHoveringAdjConflict'),
  hoverInstitutionConflict: function() {
    if (this.get('adjorTeam').get('activeHoveringInstitutionConflict') === true) {
      return 'hover-institution-conflict';
    }
  }.property('adjorTeam.activeHoveringInstitutionConflict'),

  // Hover triggers for conflict
  // TODO can merge isAdj with the else but mapping the various types

  mouseEnter: function(event) {

    if (this.isAdj) {

      // Conflicts
      this.get('adjorTeam').get('adjConflictsWithOutSelf').forEach(function(adjConflict) {
        adjConflict.set('activeHoveringAdjConflict', true);
      });
      this.get('adjorTeam').get('teamConflicts').forEach(function(teamConflict) {
        teamConflict.get('team').set('activeHoveringTeamConflict', true);
      });
      this.get('adjorTeam').get('institution').get('teams').forEach(function(insitutionalTeam) {
        insitutionalTeam.set('activeHoveringInstitutionConflict', true);
      });
      this.get('adjorTeam').set('activeHoveringInstitutionConflict', false); // Dont highlight the current adj

      // Histories
      this.get('adjorTeam').get('teamHistory').forEach(function(historyItem) {
        historyItem.get('team').set('activeHoveringHistoryConflict', true);
      });
      this.get('adjorTeam').get('adjHistory').forEach(function(historyItem) {
        historyItem.get('adj1').set('activeHoveringHistoryConflict', true);
        historyItem.get('adj2').set('activeHoveringHistoryConflict', true);
      });
      this.get('adjorTeam').set('activeHoveringHistoryConflict', false); // Dont highlight the current adj


    } else {

      this.get('adjorTeam').get('adjConflicts').forEach(function(teamConflict) {
        teamConflict.get('adjudicator').set('activeHoveringTeamConflict', true);
      });
      this.get('adjorTeam').get('adjHistory').forEach(function(historyItem) {
        historyItem.get('adjudicator').set('activeHoveringHistoryConflict', true);
      });
      this.get('adjorTeam').get('institution').get('adjudicators').forEach(function(insitutionalAdj) {
        insitutionalAdj.set('activeHoveringInstitutionConflict', true);
      });

    }
    $(".hover-key").hide();

  },

  mouseLeave: function(event) {


    if (this.isAdj) {

      // Conflicts
      this.get('adjorTeam').get('adjConflictsWithOutSelf').forEach(function(adjConflict) {
        adjConflict.set('activeHoveringAdjConflict', false); // TODO will break
      });
      this.get('adjorTeam').get('teamConflicts').forEach(function(teamConflict) {
        teamConflict.get('team').set('activeHoveringTeamConflict', false);
      });
      this.get('adjorTeam').get('institution').get('teams').forEach(function(insitutionalTeam) {
        insitutionalTeam.set('activeHoveringInstitutionConflict', false);
      });
      // Histories
      this.get('adjorTeam').get('adjHistory').forEach(function(historyItem) {
        historyItem.get('adj1').set('activeHoveringHistoryConflict', false);
        historyItem.get('adj2').set('activeHoveringHistoryConflict', false);
      });
      this.get('adjorTeam').get('teamHistory').forEach(function(historyItem) {
        historyItem.get('team').set('activeHoveringHistoryConflict', false);
      });

    } else {
      this.get('adjorTeam').get('adjConflicts').forEach(function(teamConflict) {
        teamConflict.get('adjudicator').set('activeHoveringTeamConflict', false);
      });
      this.get('adjorTeam').get('adjHistory').forEach(function(historyItem) {
        historyItem.get('adjudicator').set('activeHoveringHistoryConflict', false);
      });
      this.get('adjorTeam').get('institution').get('adjudicators').forEach(function(insitutionalAdj) {
        insitutionalAdj.set('activeHoveringInstitutionConflict', false);
      });

    }
    $(".hover-key").show();

  },

});
