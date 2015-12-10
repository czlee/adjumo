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

    toggleGender: function() {
      console.log("Toggling adj");
    },

    adjDrag: function(obj) {
      // console.log('starting adj drag');
      // console.log(obj);
      // console.log(ops);
    },

    adjDrop: function(obj) {
      console.log('did an adj drop');

      var adj = this.$(obj[0]);

      console.log(adj);
      console.log(adj.get('model'));
      console.log(adj.get('sefa'));
      console.log(adj.get('context')); // the actual div

      var toPosition = obj[1];
      //console.log(toPosition);
      var fromPosition = obj[2];
      //console.log(fromPosition);
    },

  }

});
