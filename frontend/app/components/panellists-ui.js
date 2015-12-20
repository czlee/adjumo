import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  tagName: 'section',

  drop: function(event) {
    console.log('drop to panellist UI');

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);
    var droppedAdjOldPanel = droppedAdj.get('panel');

    // Stop highlighting their conflicts
    var institutionConflict = ".institution-" + String(droppedAdj.get('institution').get('id'));
    $(institutionConflict).removeClass("institution-conflict");

    // If coming from somewhere
    if (droppedAdjOldPanel.get('content')) {
      if (droppedAdj === droppedAdjOldPanel.get('chair').get('content')) {
        droppedAdjOldPanel.set('chair', null);
      } else if (droppedAdjOldPanel.get('panellists').contains(droppedAdj)) {
        droppedAdjOldPanel.get('panellists').removeObject(droppedAdj);
      } else if (droppedAdjOldPanel.get('trainees').contains(droppedAdj)) {
        droppedAdjOldPanel.get('trainees').removeObject(droppedAdj);
      }
    }

    this.get('panel').get('panellists').addObject(droppedAdj);

    return this._super(event);

  }


});