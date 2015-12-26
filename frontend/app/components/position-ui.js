import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  tagName: 'section',
  classNames: ['droppable-area', 'position-holder'],
  classNameBindings: ['type'],

  drop: function(event) {
    var positionType = this.type;

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);
    var droppedAdjOldPanel = droppedAdj.get('panel');
    var droppedAdjNewPanel = this.get('panel');

    function removeFromOldPanel(adjToRemove, panelToRemoveFrom) {
      if (panelToRemoveFrom.get('content') !== null) {
        // If not coming from the unused area
        if (panelToRemoveFrom.get('trainees').contains(adjToRemove)) {
          panelToRemoveFrom.get('trainees').removeObject(adjToRemove);
        } else if (panelToRemoveFrom.get('panellists').contains(adjToRemove)) {
          panelToRemoveFrom.get('panellists').removeObject(adjToRemove);
        } else if (panelToRemoveFrom.get('chair').get('id') == adjToRemove.get('id')) {
          console.log('was previously a chair; removing')
          panelToRemoveFrom.set('chair', null);
        }
      }
    }

    // Check which position it is being dropped into
    switch (positionType) {
      case 'trainees':
        removeFromOldPanel(droppedAdj, droppedAdjOldPanel);
        droppedAdjNewPanel.get('trainees').addObject(droppedAdj);
        break;
      case 'panellists':
        removeFromOldPanel(droppedAdj, droppedAdjOldPanel);
        droppedAdjNewPanel.get('panellists').addObject(droppedAdj);
        break;
      case 'chair':
        //var currentChair = droppedAdjNewPanel.get('chair');
        removeFromOldPanel(droppedAdj, droppedAdjOldPanel);
        droppedAdjNewPanel.set('chair', droppedAdj);

        // if (droppedAdjOldPanel.get('chair') !== undefined && droppedAdj.get('id') === droppedAdjOldPanel.get('chair').get('id')) {
        //   // If being dropped into an occupied chairship and used to be in a chairship
        //   console.log('used to be a cahir');
        //   droppedAdjOldPanel.set('chair', currentChair);
        // } else {
        // }
        // if (droppedAdjOldPanel.get('panel').get('content') !== undefined) {
        //   // If NOT coming from unused
        //     if (this.get('panel').get('id') === droppedAdjOldPanel.get('id')) {
        //       // If coming from the same panel we just remove the old position and set the new one
        //       // Current chair will move to unused
        //       console.log('coming from same panel');
        //       removeFromOldPanel(droppedAdj, droppedAdjOldPanel);
        //       droppedAdjNewPanel.set('chair', droppedAdj);
        //     }
        // } else {
        //   // Is coming from unused; easy
        //   console.log('coming from unused');
        //   this.get('panel').set('chair', droppedAdj); // Will automatically move the current chair to unused, if it exists
        // }
        // else if (droppedAdjOldPanel.get('panel') === undefined) {
        //   // If coming from unused
        //   console.log('coming from unused');
        //   this.get('panel').set('chair', droppedAdj); // Will automatically move the current chair to unused, if it exists
        // } else if (droppedAdj.get('id') === droppedAdjOldPanel.get('chair').get('id')) {
        //   // If being dropped into an occupied chairship and used to be in a chairship
        //   console.log('into an occupied chair and used to be a chair');
        //   droppedAdjOldPanel.set('chair', this.get('panel').get('chair')); // Set the old panel's chair to be the current chair
        //   this.get('panel').set('chair', droppedAdj); // Set the dropped upon panels chair to be the dropped adj
        // } else if (this.get('panel').get('chair').get('content') === null) {
        //   // If being dropped into a blank position
        //   console.log('into a blank chair');
        //   droppedAdjNewPanel.set('chair', droppedAdj);
        //   removeFromOldPanel(droppedAdj, droppedAdjOldPanel); // Remove all previous positions
        // }
        // } else if (droppedAdj.get('id') === droppedAdjOldPanel.get('chair').get('id')) { // WORKS
        //   // If being dropped into an occupied chairship and used to be in a chairship
        //   console.log('into an occupied chair and used to be a chair');
        //   droppedAdjOldPanel.set('chair', this.get('panel').get('chair')); // Set the old panel's chair to be the current chair
        //   this.get('panel').set('chair', droppedAdj); // Set the dropped upon panels chair to be the dropped adj
        // } else {
        //   console.log('from unsed or from a previous non chairing position');
        //   // Must have been dragged from unused/trainee/panellist position into an occupied chairship
        //
        //   removeFromOldPanel(droppedAdj, droppedAdjOldPanel); // Remove all previous positions
        // }
        break;
    }

    // Remove hover conflicts when dropped
    droppedAdj.get('teamAdjHistories').forEach(function(history) {
      history.set('hoverActive', false);
    });
    droppedAdj.get('teamAdjConflicts').forEach(function(conflict) {
      conflict.set('hoverActive', false);
    });
    droppedAdj.get('adjAdjConflicts').forEach(function(conflict) {
      conflict.set('hoverActive', false);
    });
    droppedAdj.get('adjAdjHistories').forEach(function(history) {
      history.set('hoverActive', false);
    });
    droppedAdj.get('institution').set('hoverActive', false);
    $(".hover-key").show();

    return this._super(event);
  }


});
