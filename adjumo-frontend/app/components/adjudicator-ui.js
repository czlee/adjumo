import Ember from 'ember';

export default Ember.Component.extend({

  attributeBindings: 'draggable',
  draggable: 'true',

  dragStart: function(event) {
    console.log('adj UI started being dragged');

    // Let the controller know this view is dragging
    //this.set("content.isDragging", true); // PB: unclear why im doing this

    // Setup the variables that will communicate with the droppable element
    var dataTransfer = event.originalEvent.dataTransfer;
    dataTransfer.setData('AdjID', this.get('adj').get('id'));
    dataTransfer.setData('PanelID', this.get('adj').get('panel').get('id'));

    //dataTransfer.setData('Text', this.get('elementId'));

  },
  dragEnd: function(event) {
    //console.log('adj UI stopped being dragged');

    // Let the controller know this view is done dragging
    //this.set("content.isDragging", false); // PB: unclear why am doing this

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

});
