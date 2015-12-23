import Ember from 'ember';
import DraggableMixin from '../../mixins/draggable'; // Draggable inherits from adjOrTeam

export default Ember.Component.extend(DraggableMixin, {

  attributeBindings: 'draggable',
  tagName: 'button',
  draggable: 'true',

  classNames: ['btn', 'adjudicator-ui', 'ranking-display', 'js-drag-handle', 'popover-trigger'],
  classNameBindings: ['ranking', 'locked'],

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

  locked: function() {
    return 'locked-' + String(this.get('adj').locked);
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

  dragEnd: function(event) {
    // Let the controller know this view is done dragging
    return this._super(event);
  },

  actions: {

    // lockAdj: function() {
    //   this.get('adj').set('locked', true);
    //   // this.sendAction('setAdjLocked', this.get('adj')); sends an action the route which can then change the store
    // },
    // unlockAdj: function() {
    //   this.get('adj').set('locked', false);
    //   // this.sendAction('setAdjUnlocked', this.get('adj'));sends an action the route which can then change the store
    // }

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