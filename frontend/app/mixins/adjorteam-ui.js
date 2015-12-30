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
    'hasActivePanelInstitutionalConflicts:panel-institution-conflict',

    'hasActiveHoverTeamAdjHistories',
    'hasActivePanelTeamAdjHistories',

    'hasActiveHoverTeamAdjConflicts:hover-team-adj-conflict',
    'hasActivePanelTeamAdjConflicts:panel-team-adj-conflict',

  ],

  // INSTITUTIONAL CONFLICTS
  hasActiveHoverInstitutionConflict: Ember.computed('adjorTeam.institution.hoverActive', function() {
    return this.get('adjorTeam').get('institution').get('hoverActive');
  }),
  hasActivePanelInstitutionalConflicts: Ember.computed('adjorTeam.hasInstitutionalConflict', function() {
    //console.log('observed change in hasInstitutionalConflict for ' + this.get('adjorTeam').get('name'));
    return this.get('adjorTeam').get('hasInstitutionalConflict');
  }),

  // TEAM ADJ HISTORIES
  hasActiveHoverTeamAdjHistories: Ember.computed('adjorTeam.teamAdjHistories.content.@each.hoverActive', function() {
    var intensities = this.get('adjorTeam').get('teamAdjHistories').filterBy('hoverActive', true);
    if (intensities.get('length') === 1) {
      // If its zero there are no conflicts; if its > 1 its the adj or team we are hovering over
      return 'hover-team-adj-history tah-intensity-' + intensities.get('firstObject').get('historyIntensity'); // Fetch the class from the conflict object
    } else { return false; }
  }),
  hasActivePanelTeamAdjHistories: Ember.computed('adjorTeam.teamAdjHistories.content.@each.panelActive', function() {
    var intensities = this.get('adjorTeam').get('teamAdjHistories').filterBy('panelActive', true)
    if (intensities.get('length') === 1) {
      // If its zero there are no conflicts; if its > 1 its the adj or team we are hovering over
      return 'panel-team-adj-history tah-intensity-' + intensities.get('firstObject').get('historyIntensity'); // Fetch the class from the conflict object
    } else { return false; }
  }),

  // TEAM ADJ CONFLICTS
  hasActiveHoverTeamAdjConflicts: Ember.computed('adjorTeam.teamAdjConflicts.content.@each.hoverActive', function() {
    var activeConflicts = this.get('adjorTeam').get('teamAdjConflicts').filterBy('hoverActive', true).get('length');
    if (activeConflicts > 0) { return true; } else { return false; }
  }),
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
    $("#wrap").addClass("hover-display");

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
    $("#wrap").removeClass("hover-display");

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
