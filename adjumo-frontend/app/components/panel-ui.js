import Ember from 'ember';

export default Ember.Component.extend({

  actions: {

    receivedAdj: function(adjudicator, ops) {

      var position = ops.target.position;
      var debate = Ember.get(ops.target.panel, 'debate') // .;
      console.log(adjudicator);
      console.log(ops);
      console.log("move " +  Ember.get(adjudicator, 'name') + " to " + position + " on " + debate);

      this.get('chair');
      console.log(chair.name);

    },

    calculateRating: function() {

    }

  }

});
