import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  tagName: 'section',

  drop: function(event) {
    console.log('drop to chair UI');

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);
    var droppedAdjOldPanel = droppedAdj.get('panel');


    // If the dropped adj is coming from a Panel
    if (droppedAdjOldPanel.get('content')) {
      if (droppedAdj === droppedAdjOldPanel.get('chair').get('content')) {
        // If coming from a chair, do a swap
        var currentAdj = this.get('panel').get('chair');
        droppedAdjOldPanel.set('chair', currentAdj);
      } else if (droppedAdjOldPanel.get('panellists').contains(droppedAdj)) {
        droppedAdjOldPanel.set('panellists', droppedAdjOldPanel.get('panellists').removeObject(droppedAdj));
      } else if (droppedAdjOldPanel.get('trainees').contains(droppedAdj)) {
        droppedAdjOldPanel.set('trainees', droppedAdjOldPanel.get('trainees').removeObject(droppedAdj));
      }
    }

    this.get('panel').set('chair', droppedAdj);

    return this._super(event);
  }

});