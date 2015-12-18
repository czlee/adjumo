import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  tagName: 'section',

  drop: function(event) {
    console.log('drop to chair UI');

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);
    var droppedAdjOldPanel = droppedAdj.get('panel');

    var currentAdj = this.get('panel').get('chair');
    var currentAdjID = currentAdj.id;

    if (droppedAdj === droppedAdjOldPanel.get('chair').get('content')) {
      // If the dropped adj was previously in the chairing position
      console.log('coming form chair');
      if (currentAdj) {
        droppedAdjOldPanel.set('chair', currentAdj); // Set the previous chair position as the adj dropped upon
      }

    } else if (droppedAdjOldPanel.get('panellists').contains(droppedAdj)) {
      // If the dropped adj was previously a panellist
      droppedAdjOldPanel.get('panellists').removeObject(droppedAdj); // Remove the dropped adj from the previous panel

      if (currentAdj.get('content')) {
        // If the chairing position dropped to is NOT currently occupied
        if (droppedAdjOldPanel.get('panellists').get('length') > 0) {
          // Stupid hack seemingly needed here to reconstruct an array of pannelists
          // For some reason we cant just oldPanellists.pushObject(currentAdj);
          console.log('test1');
          var newPanel = [currentAdj];
          droppedAdjOldPanel.get('panellists').forEach(function(item) {
            newPanel.push(item);
          });
          droppedAdjOldPanel.set('panellists', newPanel);
        } else {
          console.log('test2');
          droppedAdjOldPanel.set('panellists', [currentAdj]); // If the previous panel is empty we can just move them directly
        }
      }
    } else if (droppedAdjOldPanel.get('trainees').contains(droppedAdj)) {
      // If the dropped adj was previously a trainee
      droppedAdjOldPanel.get('trainees').removeObject(droppedAdj);

      if (currentAdj.get('content')) {
        // If the chairing position dropped to is NOT currently occupied
        if (droppedAdjOldPanel.get('trainees').get('length') > 0) {
          // Stupid hack seemingly needed here to reconstruct an array of pannelists
          // For some reason we cant just oldPanellists.pushObject(currentAdj);
          var newPanel = [currentAdj];
          droppedAdjOldPanel.get('trainees').forEach(function(item) {
            newPanel.push(item);
          });
          droppedAdjOldPanel.set('trainees', newPanel);
        } else {
          droppedAdjOldPanel.set('trainees', [currentAdj]); // If the previous panel is empty we can just move them directly
        }
      }
    }
    this.get('panel').set('chair', droppedAdj); // Set the dropped chair position as the dropped adj

    return this._super(event);
  }

});