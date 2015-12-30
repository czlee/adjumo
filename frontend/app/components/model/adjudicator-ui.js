import Ember from 'ember';
import DraggableMixin from '../../mixins/draggable'; // Draggable inherits from adjOrTeam

export default Ember.Component.extend(DraggableMixin, {

  attributeBindings: 'draggable',
  tagName: 'button',
  draggable: 'true',
  hovering: false,

  classNames: ['btn', 'adjudicator-ui', 'popover-trigger'],
  classNameBindings: ['ranking', 'hovering:hovering:not-hovering',

    'hasActiveHoverAdjAdjHistories',
    'hasActivePanelAdjAdjHistories',

    'hasActiveHoverAdjAdjConflicts:hover-adj-adj-conflict',
    'hasActivePanelAdjAdjConflicts:panel-adj-adj-conflict',

  ],

  // ADJ ADJ HISTORIES
  hasActiveHoverAdjAdjHistories: Ember.computed('adj.adjAdjHistories.content.@each.hoverActive', function() {
    var intensities = this.get('adj').get('adjAdjHistories').filterBy('hoverActive', true);
    if (intensities.get('length') === 1) { // If its zero there are no conflicts; if its > 1 its the adj or team we are hovering over
      return 'hover-adj-adj-history aah-intensity-' + intensities.get('firstObject').get('historyIntensity'); // Fetch the class from the conflict object
    } else { return false; }
  }),
  hasActivePanelAdjAdjHistories: Ember.computed('adj.adjAdjHistories.content.@each.panelActive', function() {
    var intensities = this.get('adj').get('adjAdjHistories').filterBy('panelActive', true);
    if (intensities.get('length') === 1) { // If its zero there are no conflicts; if its > 1 its the adj or team we are hovering over
      return 'panel-adj-adj-history aah-intensity-' + intensities.get('firstObject').get('historyIntensity'); // Fetch the class from the conflict object
    } else { return false; }
  }),
  // ADJ ADJ CONFLICTS
  hasActiveHoverAdjAdjConflicts: Ember.computed('adj.adjAdjConflicts.content.@each.hoverActive', function() {
    var activeConflicts = this.get('adj').get('adjAdjConflicts').filterBy('hoverActive', true).get('length');
    if (activeConflicts > 0) { return true; } else { return false; }
  }),
  hasActivePanelAdjAdjConflicts: Ember.computed('adj.adjAdjConflicts.content.@each.panelActive', function() {
    var activeConflicts = this.get('adj').get('adjAdjConflicts').filterBy('panelActive', true).get('length');
    //console.log('observed conflict for ' + this.get('adjorTeam').get('name') + ' has ' + activeConflicts);
    if (activeConflicts > 0) { return true; } else { return false; }
  }),


  adjorTeam: Ember.computed('adj', function() {
    return this.get('adj'); // normalise to 1-9 like adjs
  }),
  isAdj: true,

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

  ranking: function() {
    return 'ranking-' + String(this.get('adj').get('ranking'));
  }.property('adj'),

  dragStart: function(event) {
    this.$().popover('hide'); // Is annoying while dragging
    // Setup the variables that will communicate with the droppable element
    var dataTransfer = event.originalEvent.dataTransfer;
    dataTransfer.setData('AdjID', this.get('adj').get('id'));
    var containerElement = this.$().parent();

    if (containerElement.hasClass("debate-bans")) {
      dataTransfer.setData('fromType', 'bans');
      var debateID = containerElement.parent().attr('class').split('debate-')[1];
      dataTransfer.setData('debateID', debateID);
    } else if (containerElement.hasClass("debate-locks")) {
      dataTransfer.setData('fromType', 'locks');
    } else if (containerElement.hasClass("all-adjs-panel")) {
      dataTransfer.setData('fromType', 'all-adjs');
    } else if (containerElement.hasClass("unused-adjs-panel")) {
      dataTransfer.setData('fromType', 'unused-adjs');
    } else if (containerElement.hasClass("chair")) {
      dataTransfer.setData('fromType', 'chair');
      dataTransfer.setData('PanelID', this.get('adj').get('panel').get('id'));
    } else if (containerElement.hasClass("panellists")) {
      dataTransfer.setData('fromType', 'panellists');
      dataTransfer.setData('PanelID', this.get('adj').get('panel').get('id'));
    } else if (containerElement.hasClass("trainee")) {
      dataTransfer.setData('fromType', 'trainees');
      dataTransfer.setData('PanelID', this.get('adj').get('panel').get('id'));
    } else if (containerElement.hasClass("adj-group")) {
      dataTransfer.setData('fromType', 'group');
    }

    return this._super(event);
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
  },


  mouseEnter: function(event) {

    this.get('adj').get('adjAdjConflicts').forEach(function(conflict) {
      conflict.set('hoverActive', true);
    });
    this.get('adj').get('adjAdjHistories').forEach(function(history) {
      history.set('hoverActive', true);
    });
    this.set('hovering', true);
    return this._super(event);

  },


  mouseLeave: function(event) {

    this.get('adj').get('adjAdjConflicts').forEach(function(conflict) {
      conflict.set('hoverActive', false);
    });
    this.get('adj').get('adjAdjHistories').forEach(function(history) {
      history.set('hoverActive', false);
    });
    this.set('hovering', false);
    return this._super(event);

  },

  dragEnd: function(event) {

    // When dropped stopped the hover effects
    this.get('adj').get('adjAdjConflicts').forEach(function(conflict) {
      conflict.set('hoverActive', false);
    });
    this.get('adj').get('adjAdjHistories').forEach(function(history) {
      history.set('hoverActive', false);
    });
    this.set('hovering', false);
    $("#wrap").removeClass("hover-display");
    return this._super(event);

  }



});
