import Ember from 'ember';

export default Ember.Component.extend({

  tagName: 'td',

  classNames: ['team-ui hover-panel-trigger"'],
  classNameBindings: ['gender', 'region', 'institution', 'language', 'id'],

  // CSS Getters
  gender: function(){
    return 'gender-' + String(this.get('team').get('gender'));
  }.property('team'),
  region: function() {
    return 'region-' + String(this.get('team').get('region'));
  }.property('team'),
  language: function() {
    return 'language-' + String(this.get('team').get('language'));
  }.property('team'),
  institution: function() {
    return 'institution-' + String(this.get('team').get('institution').get('id'));
  }.property('team'),
  id: function() {
    return 'team-' + String(this.get('team').get('id'));
  }.property('id'),


  mouseEnter: function(event) {
    this.get('team').get('adjConflictIDs').forEach(function(id) {
      var adjConflict = ".adj-" + id;
      $(adjConflict).addClass("team-conflict");
    });
    $("#conflictsKey").show();
    $(".hover-key").hide();
  },

  mouseLeave: function(event) {
    $(".team-conflict").removeClass("team-conflict");
    $("#conflictsKey").hide();
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
