import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  drop: function(event) {
    console.log('drop to trainee UI');

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);
    var oldPanel = droppedAdj.get('panel');

    // If coming from somewhere
    if (oldPanel.get('content')) {
      if (droppedAdj === oldPanel.get('chair').get('content')) {
        oldPanel.set('chair', null);
      } else if (oldPanel.get('panellists').contains(droppedAdj)) {
        oldPanel.set('panellists', oldPanel.get('panellists').removeObject(droppedAdj));
      } else if (oldPanel.get('trainees').contains(droppedAdj)) {
        oldPanel.set('trainees', oldPanel.get('trainees').removeObject(droppedAdj));
      }
    }

    this.get('panel').get('trainees').addObject(droppedAdj);

    return this._super(event);
  }

});