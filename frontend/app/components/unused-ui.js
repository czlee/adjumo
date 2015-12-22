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

      var allAdjsResize = false;
      var allAdjsadj_area_height = $("#allAdjs.adj-bottom-panel").height();
      var unusedAdjsResize = false;
      var unusedAdjsadj_area_height = $("#unusedAdjs.adj-bottom-panel").height();

      $(document).mouseup(function(event) {
        allAdjsResize = false;
        allAdjsadj_area_height = $("#allAdjs.adj-bottom-panel").height();
        unusedAdjsResize = false;
        unusedAdjsadj_area_height = $("#unusedAdjs.adj-bottom-panel").height();
      });

      $("#allAdjs .resize-holder").mousedown(function(event) {
        allAdjsResize = event.pageY;
        event.preventDefault(); // Prevent text highlight selections  while dragging
      });

      $("#unusedAdjs .resize-holder").mousedown(function(event) {
        unusedAdjsResize = event.pageY;
        event.preventDefault(); // Prevent text highlight selections  while dragging
      });

      $(document).mousemove(function(event) {
        if (allAdjsResize) {
          if (allAdjsadj_area_height + allAdjsResize - event.pageY < 45) {
            $("#allAdjs.adj-bottom-panel").height(45);
          } else if (allAdjsadj_area_height + allAdjsResize - event.pageY > 400) {
            $("#allAdjs.adj-bottom-panel").height(400);
          } else {
            $("#allAdjs.adj-bottom-panel").height(allAdjsadj_area_height + allAdjsResize - event.pageY);
            $("#allocation").css( "margin-bottom", allAdjsadj_area_height + 25 + allAdjsResize - event.pageY);
          }
        } else if (unusedAdjsResize) {
          if (unusedAdjsadj_area_height + unusedAdjsResize - event.pageY < 45) {
            $("#unusedAdjs.adj-bottom-panel").height(45);
          } else if (unusedAdjsadj_area_height + unusedAdjsResize - event.pageY > 400) {
            $("#unusedAdjs.adj-bottom-panel").height(400);
          } else {
            $("#unusedAdjs.adj-bottom-panel").height(unusedAdjsadj_area_height + unusedAdjsResize - event.pageY);
            $("#allocation").css( "margin-bottom", unusedAdjsadj_area_height + 25 + unusedAdjsResize - event.pageY);
          }
        }
      });

    });
  }

});
