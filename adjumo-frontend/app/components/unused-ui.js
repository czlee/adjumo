import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  sortProperties: ['ranking:desc','name:asc'],
  sortedAdjudicators: Ember.computed.sort('adjudicators', 'sortProperties'),

  unusedAdjudicators: Ember.computed('adjudicators.@each.panel', function() {
    var unusedAdjudicators = new Array();
    this.get('sortedAdjudicators').forEach(function(adjudicator) {
      if (!adjudicator.get('panel').get('content')) {
        unusedAdjudicators.push(adjudicator);
      }
    });
    return unusedAdjudicators;
  }),

  drop: function(event){
    console.log('unused UI had a drop');

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);
    var oldPanel = droppedAdj.get('panel');

    if (oldPanel.get('content')) {
      if (droppedAdj === oldPanel.get('chair').get('content')) {
        oldPanel.set('chair', null);
      } else if (oldPanel.get('panellists').contains(droppedAdj)) {
        oldPanel.set('panellists', oldPanel.get('panellists').removeObject(droppedAdj));
      } else if (oldPanel.get('trainees').contains(droppedAdj)) {
        oldPanel.set('trainees', oldPanel.get('trainees').removeObject(droppedAdj));
      }
    }

    return this._super(event);

  },

});
