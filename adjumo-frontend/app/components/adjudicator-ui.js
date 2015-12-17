import Ember from 'ember';
import DraggableMixin from '../mixins/draggable';

export default Ember.Component.extend(DraggableMixin, {

  attributeBindings: 'draggable',
  draggable: 'true',

  dragStart: function(event) {
    this.$('.tooltip').hide(); // Is annoying while dragging

    // Setup the variables that will communicate with the droppable element
    var dataTransfer = event.originalEvent.dataTransfer;
    dataTransfer.setData('AdjID', this.get('adj').get('id'));
    dataTransfer.setData('PanelID', this.get('adj').get('panel').get('id'));

    //dataTransfer.setData('Text', this.get('elementId'));

    return this._super(event);
  },
  dragEnd: function(event) {
    // Let the controller know this view is done dragging
    //this.set("content.isDragging", false); // PB: unclear why am doing this

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
      this.$('[data-toggle="tooltip"]').tooltip();
    });
  }

});
