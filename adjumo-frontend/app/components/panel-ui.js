import Ember from 'ember';

export default Ember.Component.extend({

  actions: {

    startPanelDrag: function(obj,ops) {
      console.log('starting panel drag');
    },
    endPanelDrag: function(obj,ops) {
      console.log('ending panel drag');
    },

    chairReceived: function(obj,ops) {
      console.log('chair received by panel');
    },
    panellistReceived: function(obj,ops) {
      console.log('panellist received by panel');
    },
    traineeReceived: function(obj,ops) {
      console.log('trainee received by panel');
    },

  }

});
