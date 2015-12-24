import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Mixin.create(DroppableMixin, {

  sortProperties: ['ranking:desc','name:asc'],
  sortedAdjudicators: Ember.computed.sort('adjudicators', 'sortProperties'),

  classNames: ['droppable-area', 'container-fluid', 'navbar-fixed-bottom', 'adj-bottom-panel'],

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
    // console.log('unused UI had a drop');

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
      var resizingAdjsPanel = false;
      var adjsPanelHeight = $(this.typeClass).height();
      var minHeight = this.minHeight;
      var maxHeight = this.maxHeight;
      var classIdentifier = this.typeClass;

      $(document).mouseup(function(event) {
        resizingAdjsPanel = false;
        adjsPanelHeight = $(classIdentifier).height();
      });

      $(String(classIdentifier + " .resize-holder")).mousedown(function(event) {
        resizingAdjsPanel = event.pageY;
        event.preventDefault(); // Prevent text highlight selections  while dragging
      });

      $(document).mousemove(function(event) {
        if (resizingAdjsPanel) {
          if (adjsPanelHeight + resizingAdjsPanel - event.pageY < minHeight) {
            // If too short
            $(classIdentifier).height(minHeight);
          } else if (adjsPanelHeight + resizingAdjsPanel - event.pageY > maxHeight) {
            // If too tall
            $(classIdentifier).height(maxHeight);
          } else {
            // Set height
            $(classIdentifier).height(adjsPanelHeight + resizingAdjsPanel - event.pageY);
            $("#allocation").css( "margin-bottom", adjsPanelHeight + 25 + resizingAdjsPanel - event.pageY);
          }

        }
      });

    });
  }


});
