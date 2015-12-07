import Ember from 'ember';

export default Ember.Component.extend({

  actions: {
    startAdjDrag: function(obj,ops) {
      console.log('startAdjDrag');
    },
    endAdjDrag: function(obj,ops) {
      console.log('endAdjDrag');
    },
  }

});
