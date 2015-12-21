import Ember from 'ember';
import DraggableMixin from '../mixins/draggable';

export default Ember.Component.extend(DraggableMixin, {

  attributeBindings: 'draggable',
  tagName: 'button',
  draggable: 'true',

  classNames: ['btn', 'adjudicator-ui', 'ranking-display', 'js-drag-handle', 'popover-trigger'],
  classNameBindings: ['gender', 'region', 'language', 'ranking', 'locked', 'id'],

  // CSS Getters
  gender: function(){
    return 'gender-' + String(this.get('adj').get('gender'));
  }.property('adj'),
  region: function() {
    var regions = "";
    this.get('adj').get('regions').forEach(function(region) {
      regions += "region-" + region + " ";
    });
    if (this.get('adj').get('regions').length > 1) {
      regions += "multiple-regions";
    }
    return regions;
  }.property('adj'),
  language: function() {
    return 'language-' + String(this.get('adj').get('language'));
  }.property('adj'),
  ranking: function() {
    return 'ranking-' + String(this.get('adj').get('ranking'));
  }.property('adj'),
  locked: function() {
    return 'locked-' + String(this.get('adj').locked);
  }.property('adj'),
  id: function() {
    return 'adj-' + String(this.get('adj').get('id'));
  }.property('adj'),

  mouseEnter: function(event) {
    var institutionConflict = ".institution-" + String(this.get('adj').get('institution').get('id'));
    $(institutionConflict).addClass("institution-conflict");

    this.get('adj').get('teamConflictIDs').forEach(function(id) {
      var teamConflict = ".team-" + id;
      $(teamConflict).addClass("team-conflict");
    });
    this.get('adj').get('adjConflictIDs').forEach(function(id) {
      var adjConflict = ".adj-" + id;
      $(adjConflict).addClass("adj-conflict");
    });

    $("#conflictsKey").show();
    $(".hover-key").hide();

  },

  mouseLeave: function(event) {

    $(".institution-conflict").removeClass("institution-conflict");
    $(".team-conflict").removeClass("team-conflict");
    $(".adj-conflict").removeClass("adj-conflict");
    $("#conflictsKey").hide();
    $(".hover-key").show();

  },

  dragStart: function(event) {
    this.$().popover('hide'); // Is annoying while dragging

    // Setup the variables that will communicate with the droppable element
    var dataTransfer = event.originalEvent.dataTransfer;
    dataTransfer.setData('AdjID', this.get('adj').get('id'));
    dataTransfer.setData('PanelID', this.get('adj').get('panel').get('id'));

    //dataTransfer.setData('Text', this.get('elementId'));

    return this._super(event);
  },
  dragEnd: function(event) {
    // Let the controller know this view is done dragging
    return this._super(event);
  },

  //locked: Ember.computed.alias('adj.locked'),

  actions: {

    lockAdj: function() {
      this.get('adj').set('locked', true);
      // this.sendAction('setAdjLocked', this.get('adj')); sends an action the route which can then change the store
    },
    unlockAdj: function() {
      this.get('adj').set('locked', false);
      // this.sendAction('setAdjUnlocked', this.get('adj'));sends an action the route which can then change the store
    }

  },

  didInsertElement: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {

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
