import Ember from 'ember';

export default Ember.Component.extend({

  adj_dragulaconfig: {
    accepts: function (el, target, source, sibling) {
      return true; // elements can be dropped in any of the `containers` by default
    },
    options: {
        copy: false,
        revertOnSpill: false,
        removeOnSpill: false,
        direction: 'horizontal',
        // Other options from the dragula source page.
    },
    enabledEvents: ['drag', 'drop']
  },

  actions: {

    adjDrag: function(obj,ops) {
      console.log('starting panel drag');
    },

    adjDrop: function(obj,ops) {
      console.log('ending panel drag');
    },

  }

});
