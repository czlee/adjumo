import Ember from 'ember';

export default Ember.Component.extend({

  tagName: 'td',

  classNames: ['team-ui hover-panel-trigger"'],
  classNameBindings: ['gender', 'region', 'institution', 'language', 'id', 'teamConflict', 'adjConflict', 'institutionConflict', 'historyConflict'],

  team: function() { return this.get('team') },

  // CSS Getters
  gender: function(){
    return 'gender-' + String(this.team.get('gender'));
  }.property('team'),
  region: function() {
    return 'region-' + String(this.team.get('region'));
  }.property('team'),
  language: function() {
    return 'language-' + String(this.team.get('language'));
  }.property('team'),
  institution: function() {
    return 'institution-' + String(this.team.get('institution').get('id'));
  }.property('team'),
  id: function() {
    return 'team-' + String(this.team.get('id'));
  }.property('id'),

  historyConflict: function() {
    if ((this.team.get('activeHoveringHistoryConflict') == true) || (this.team.get('activePanelHistoryConflict') == true)) {
      return "history-conflict";
    }
  }.property('team.activeHoveringHistoryConflict', 'team.activePanelHistoryConflict'),

  teamConflict: function() {
    if (this.team.get('panelTeamConflict') === true) { return "panel-team-conflict"; }
  }.property('team.panelTeamConflict'),

  adjConflict: function() {
    if (this.team.get('panelAdjConflict') === true) { return "panel-adj-conflict"; }
  }.property('team.panelAdjConflict'),

  institutionConflict: function() {
    if (this.team.get('panelInstitutionConflict') === true) { return "panel-institution-conflict"; }
  }.property('team.panelInstitutionConflict'),

  mouseEnter: function(event) {
    this.team.get('adjConflictIDs').forEach(function(id) {
      var adjConflict = ".adj-" + id;
      $(adjConflict).addClass("team-conflict");
    });
    $(".hover-key").hide();
  },

  mouseLeave: function(event) {
    $(".team-conflict").removeClass("team-conflict");
    $(".hover-key").show();
  },

  didInsertElement: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      //this.$('[data-toggle="tooltip"]').tooltip();

      this.$().popover({
        html : true,
        trigger: 'hover',
        content: function() {
          return $(this).children('.hover-panel').html();
        },
        template: '<div class="popover" role="tooltip"> <div class="arrow"></div> <div class="popover-content"></div> </div>',
        placement: 'top',
        container: 'body',
      });
    });
  }



});
