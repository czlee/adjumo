import Ember from 'ember';

export default Ember.Mixin.create({

  classNameBindings: [
    'gender', 'region', 'language', 'id', 'institution',
    // 'panelHistoryConflict', 'panelTeamConflict', 'panelAdjConflict', 'panelInstitutionConflict',
    // 'hoverHistoryConflict', 'hoverTeamConflict', 'hoverAdjConflict', 'hoverInstitutionConflict',

    // 'hoverPanelTeamConflict:hoverTeamConflict:hoverPanelTeamConflict',
    // 'hoverPanelAdjConflict:hoverAdjConflict:hoverPanelAdjConflict'
    // 'activePanelTeamConflict:panelTeamConflict:noPanelTeamConflict',
    // 'activePanelAdjConflict:panelAdjConflict:noPanelAdjConflict'


    'hasActiveHoverInstitutionConflict:hover-institution-conflict',
    'hasActiveHoverTeamAdjHistories:hover-team-adj-history',
    'hasActiveHoverTeamAdjConflicts:hover-team-adj-conflict',

    'hasActivePanelTeamAdjHistories:panel-team-adj-history',
    'hasActivePanelTeamAdjConflicts:panel-team-adj-conflict',

  ],

  // HOVERS
  hasActiveHoverInstitutionConflict: Ember.computed('adjorTeam.institution.hoverActive', function() {
    return this.get('adjorTeam').get('institution').get('hoverActive');
  }),

  hasActiveHoverTeamAdjHistories: Ember.computed('adjorTeam.teamAdjHistories.content.@each.hoverActive', function() {
    var activeConflicts = this.get('adjorTeam').get('teamAdjHistories').filterBy('hoverActive', true).get('length');
    if (activeConflicts > 0) { return true; } else { return false; }
  }),

  hasActiveHoverTeamAdjConflicts: Ember.computed('adjorTeam.teamAdjConflicts.content.@each.hoverActive', function() {
    var activeConflicts = this.get('adjorTeam').get('teamAdjConflicts').filterBy('hoverActive', true).get('length');
    if (activeConflicts > 0) { return true; } else { return false; }
  }),

  // IN PANELS
  hasActivePanelTeamAdjHistories: Ember.computed('adjorTeam.teamAdjHistories.content.@each.panelActive', function() {
    var activeConflicts = this.get('adjorTeam').get('teamAdjHistories').filterBy('panelActive', true).get('length');
    //console.log('computed change in hasActivePanelTeamAdjHistories for ' + this.get('adjorTeam').get('name') + 'set to ' + activeConflicts);
    if (activeConflicts > 0) { return true; } else { return false; }
  }), // Works

  hasActivePanelTeamAdjConflicts: Ember.computed('adjorTeam.teamAdjConflicts.content.@each.panelActive', function() {
    var activeConflicts = this.get('adjorTeam').get('teamAdjConflicts').filterBy('panelActive', true).get('length');
    //console.log('computed change in hasActivePanelTeamAdjConflicts for ' + this.get('adjorTeam').get('name') + 'set to ' + activeConflicts);
    if (activeConflicts > 0) { return true; } else { return false; }
  }),

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

  // Hover triggers for conflicts

  mouseEnter: function(event) {

    this.get('adjorTeam').get('teamAdjHistories').forEach(function(history) {
      history.set('hoverActive', true);
    });
    this.get('adjorTeam').get('teamAdjConflicts').forEach(function(conflict) {
      conflict.set('hoverActive', true);
    });
    this.get('adjorTeam').get('institution').set('hoverActive', true);

    $(".hover-key").hide();

  },

  mouseLeave: function(event) {

    this.get('adjorTeam').get('teamAdjHistories').forEach(function(history) {
      history.set('hoverActive', false);
    });
    this.get('adjorTeam').get('teamAdjConflicts').forEach(function(conflict) {
      conflict.set('hoverActive', false);
    });
    this.get('adjorTeam').get('institution').set('hoverActive', false);

    $(".hover-key").show();

  },

  dragEnd: function(event) {

    // When dropped stopped displaying conflicts
    this.get('adjorTeam').get('teamAdjHistories').forEach(function(history) {
      history.set('hoverActive', false);
    });
    this.get('adjorTeam').get('teamAdjConflicts').forEach(function(conflict) {
      conflict.set('hoverActive', false);
    });
    this.get('adjorTeam').get('institution').set('hoverActive', false);

    return this._super(event);

  }


});
