import Ember from 'ember';

export default Ember.Component.extend({

  actions: {

    startPanelDrag: function(obj,ops) {
      console.log('starting panel drag');
    },
    endPanelDrag: function(obj,ops) {
      console.log('ending panel drag');
    },

    receivedAdj: function(adjudicator, ops) {
      var position = ops.target.position;
      var debate = Ember.get(ops.target.panel, 'debate') // .;
      console.log(adjudicator);
      console.log(ops);
      console.log("move " +  Ember.get(adjudicator, 'name') + " to " + position + " on " + debate);

    }

  }

});
