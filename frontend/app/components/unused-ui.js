import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  sortProperties: ['ranking:desc','name:asc'],
  sortedAdjudicators: Ember.computed.sort('adjudicators', 'sortProperties'),

  unusedAdjudicators: Ember.computed('adjudicators.@each.panel', function() {
    var unusedAdjudicators = [];
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
        oldPanel.get('panellists').removeObject(droppedAdj);
      } else if (oldPanel.get('trainees').contains(droppedAdj)) {
        oldPanel.get('trainees').removeObject(droppedAdj);
      }
    }

    // Remove all conflicts
    droppedAdj.set('panelTeamConflict', false);
    droppedAdj.set('panelAdjConflict', false);
    droppedAdj.set('panelInstitutionConflict', false);

    return this._super(event);

  },


  didInsertElement: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {

      var resize = false;
      var adj_area_height = $(".adj-bottom-panel").height();

      $(document).mouseup(function(event) {
        resize = false;
        adj_area_height = $(".adj-bottom-panel").height();
      });

      $(".resize-holder").mousedown(function(event) {
        resize = event.pageY;
        event.preventDefault(); // Prevent text highlight selections  while dragging
      });

      $(document).mousemove(function(event) {
        if (resize) {
          if (adj_area_height + resize - event.pageY < 50) {
            $(".adj-bottom-panel").height(50);
          } else if (adj_area_height + resize - event.pageY > 400) {
            $(".adj-bottom-panel").height(400);
          } else {
            $(".adj-bottom-panel").height(adj_area_height + resize - event.pageY);
            $("#allocation").css( "margin-bottom", adj_area_height + 25 +resize - event.pageY);

          }
        }
      });

    });
  }

});
