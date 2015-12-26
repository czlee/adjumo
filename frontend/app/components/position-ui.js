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

    if (positionType === 'chair') {
      // If coming from a chair
      var hasCurrentAdj = this.get('panel').get('chair').get('content');

      if (droppedAdj === droppedAdjOldPanel.get('chair').get('content')) {
        // If the dropped adj was previously in the chairing position
        if (hasCurrentAdj !== null) {
          droppedAdjOldPanel.set('chair', this.get('panel').get('chair')); // Set the previous chair position as the adj dropped upon
          this.get('panel').get('chair').set('panel', droppedAdjOldPanel);
        } else {
          droppedAdjOldPanel.set('chair', null); // Set the previous chair position as the adj dropped upon
        }
      } else if (droppedAdjOldPanel.get('panellists').contains(droppedAdj)) {
        // If the dropped adj was previously a panellist
        droppedAdjOldPanel.get('panellists').removeObject(droppedAdj); // Remove the dropped adj from the previous panel

        if (hasCurrentAdj !== null) {
          // If the chairing position dropped to is NOT currently occupied
          if (droppedAdjOldPanel.get('panellists').get('length') > 0) {
            // Stupid hack seemingly needed here to reconstruct an array of pannelists
            // For some reason we cant just oldPanellists.pushObject(currentAdj);
            var newPanel = [this.get('panel').get('chair')];
            droppedAdjOldPanel.get('panellists').forEach(function(item) {
              newPanel.push(item);
            });
            droppedAdjOldPanel.set('panellists', newPanel);
          } else {
            droppedAdjOldPanel.set('panellists', [this.get('panel').get('chair')]); // If the previous panel is empty we can just move them directly
          }
        }
      } else if (droppedAdjOldPanel.get('trainees').contains(droppedAdj)) {
        // If the dropped adj was previously a trainee
        droppedAdjOldPanel.get('trainees').removeObject(droppedAdj);

        if (hasCurrentAdj !== null) {
          // If the chairing position dropped to is NOT currently occupied
          if (droppedAdjOldPanel.get('trainees').get('length') > 0) {
            // Stupid hack seemingly needed here to reconstruct an array of pannelists
            // For some reason we cant just oldPanellists.pushObject(currentAdj);
            var newPanel = [this.get('panel').get('chair')];
            droppedAdjOldPanel.get('trainees').forEach(function(item) {
              newPanel.push(item);
            });
            droppedAdjOldPanel.set('trainees', newPanel);
          } else {
            droppedAdjOldPanel.set('trainees', [this.get('panel').get('chair')]); // If the previous panel is empty we can just move them directly
          }
        }
      }

    } else {
      // If coming from not being a chiar
      if (droppedAdjOldPanel.get('content')) {
        if (droppedAdj === droppedAdjOldPanel.get('chair').get('content')) {
          droppedAdjOldPanel.set('chair', null);
        } else if (droppedAdjOldPanel.get('panellists').contains(droppedAdj)) {
          droppedAdjOldPanel.get('panellists').removeObject(droppedAdj);
        } else if (droppedAdjOldPanel.get('trainees').contains(droppedAdj)) {
          droppedAdjOldPanel.get('trainees').removeObject(droppedAdj);
        }
      }
    }

    switch (positionType) {
      case 'trainees':
        this.get('panel').get('trainees').addObject(droppedAdj);
        break;
      case 'panellists':
        this.get('panel').get('panellists').addObject(droppedAdj);
        break;
      case 'chair':
        this.get('panel').set('chair', droppedAdj);
        break;
    }

    droppedAdj.set('panel', this.get('panel'));


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
