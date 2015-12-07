import Ember from 'ember';

export default Ember.Component.extend({

  dragulaconfig: {
    options: {
        copy: false,
        revertOnSpill: false,
        removeOnSpill: false,
        direction: 'horizontal',
        // Other options from the dragula source page.
    },
    enabledEvents: ['drag', 'drop']
  },

});
