import Ember from 'ember';

export default Ember.Component.extend({

  unusedAdjudicators: Ember.computed('adjudicators.@each.panel', function() {
    var unusedAdjudicators = new Array();
    this.get('adjudicators').forEach(function(adjudicator) {
      if (!adjudicator.get('panel').get('content')) {
        unusedAdjudicators.push(adjudicator);
      }
    });
    return unusedAdjudicators;
  }),

  drop: function(event){
    console.log('unused UI had a drop');
    event.preventDefault();

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);
    var oldPanel = droppedAdj.get('panel');

    if (oldPanel) {
      if (droppedAdj === oldPanel.get('chair').get('content')) {
        oldPanel.set('chair', null);
      } else if (oldPanel.get('panellists').contains(droppedAdj)) {
        oldPanel.set('panellists', oldPanel.get('panellists').removeObject(droppedAdj));
      } else if (oldPanel.get('trainees').contains(droppedAdj)) {
        oldPanel.set('trainees', oldPanel.get('trainees').removeObject(droppedAdj));
      }
    }

    return false;

  },

  dragOver: function(event){
    event.preventDefault(); // this is needed to avoid the default behaviour from the browser
  },

  dragEnter: function(event){
    console.log('unused UI had a drag enter');
    event.preventDefault();
    return false;
  },

  dragLeave: function(event){
    console.log('unused UI had a drag leave');
    event.preventDefault();
    return false;
  },


});
