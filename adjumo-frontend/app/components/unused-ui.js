import Ember from 'ember';

export default Ember.Component.extend({

  unusedAdjudicators: Ember.computed('adjudicators.@each.panel', function() {
    var unusedAdjudicators = new Array();
    this.get('adjudicators').forEach(function(adjudicator) {
      if (!adjudicator.get('panel').get('content')) {
        unusedAdjudicators.push(adjudicator);
      }
    });
    return unusedAdjudicators;
  }),

  drop: function(event){
    console.log('unused UI had a drop');
    event.preventDefault();

    var adjudicatorObject = event.originalEvent.dataTransfer.getData('Adjudicator');
    console.log(adjudicatorObject);

    var viewId = event.originalEvent.dataTransfer.getData('Text');
    console.log(viewId);
    var view = Ember.View.views[viewId];
    console.log(view);

    // Set view properties
    // Must be within `Ember.run.next` to always work
    Ember.run.next(this, function() {
        view.setPath('content.isAdded', !view.getPath('content.isAdded'));
    });

    view.appendTo(this);
    return false;

  },

  dragOver: function(event){
    event.preventDefault(); // this is needed to avoid the default behaviour from the browser
  },

  dragEnter: function(event){
    console.log('unused UI had a drag enter');
    event.preventDefault();
    return false;
    //this.set('isDragging', true);
  },

  dragLeave: function(event){
    console.log('unused UI had a drag leave');
    event.preventDefault();
    return false;
    //this.set('isDragging', false);
  },


});
